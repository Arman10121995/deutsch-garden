# Platforms

One codebase, six targets. Everything under `lib/` is identical on every
platform — the same 10,000 cards, 207 grammar lessons, 60 stories, 60
role-plays, course spine, audio course, SM-2 scheduler and exam bank. Only the
generated platform wrapper differs, and it is generated from the installed
Flutter SDK rather than committed.

| Target | Artifact | Source branch | Speech synthesis | Speech recognition |
| --- | --- | --- | --- | --- |
| Android | `DeutschGarden.apk` | `main` | German OS voices rendered to a private seekable WAV | OS recogniser |
| Windows | `DeutschGarden-windows-x64.zip` (`.exe` inside) | `main` | Two bundled neural voices; SAPI fallback | `speech_to_text_windows` |
| macOS | `DeutschGarden-macos.zip` (`.app`) | `main` | Two bundled neural voices; OS fallback | Speech framework |
| iOS | `DeutschGarden-ios-unsigned.ipa` | `main` | Two bundled neural voices; OS fallback | Speech framework |
| Linux | AppImage and `.tar.gz` | `main` | Two bundled neural voices; local command fallback | **none** |
| Web | `DeutschGarden-web.tar.gz` | `main` | Browser voice | Browser-dependent |

`main` carries the full cross-platform source. A tagged release builds every
target in one CI matrix; there are no platform branches and therefore no
branch-specific code to drift.

## Is it really all offline?

Yes, with one honest caveat.

**Baked into the binary:** every vocabulary card, grammar lesson, listening
script, reading text, writing prompt, speaking lesson, story chapter, role-play
turn, practice sentence, placement item and exam mock. They are Dart constants
compiled into the executable. There is no asset download, no first-run sync, no
CDN, no API, and no DeutschGarden server anywhere.

**Bundled by the app:** builds include two CC0 German neural-voice model assets
(about 126 MB). Windows, macOS, iOS and Linux run them locally through
sherpa-onnx. Android 4.5 deliberately never initialises sherpa after its 1.13.6
native generator proved unstable there; it instead renders installed German OS
voices locally into a private WAV. The web build uses browser voices because a
browser has no ordinary file path from which sherpa can load the models.

**Provided by your operating system:** speech recognition, and the fallback
speech synthesiser used only if the bundled voice cannot load.

**The caveat:** on Android and iOS, the *system* speech recogniser may route
audio through the vendor's servers unless you install an offline language pack.
That is the platform's behaviour, not this app's, and this app cannot override
it. If that matters to you, install the German offline pack — or use typed
input, which every speaking exercise accepts and scores identically.

## The web build

`flutter build web --release` produces a PWA in `build/web`. It is the same
`lib/` as every other target.

Two things make it behave like the rest of the app rather than like a website:

- **CanvasKit is self-hosted.** The Flutter loader fetches its renderer from
  `https://www.gstatic.com/flutter-canvaskit` unless told otherwise, even though
  the build already copies CanvasKit into `build/web/canvaskit/`. For an app
  whose premise is that it never contacts a server, that is both a broken
  promise and a hard failure anywhere the CDN is unreachable.
  `tool/patch_platforms.py` writes a `web/flutter_bootstrap.js` that pins
  `canvasKitBaseUrl` to the local copy, and CI fails the build if that pin is
  missing. A loaded page makes no external requests at all.
- **The service worker caches the app**, so after the first load it runs with
  the network off, like every other platform.

### What the web build cannot do

- **Speech recognition** depends on the browser's Web Speech API. Chrome and
  Edge implement it; Firefox does not. Where it is missing the app falls back to
  typed input, exactly as it does on Linux.
- **Speech synthesis** uses the browser's voices. A German voice has to be
  installed in the operating system; quality varies more than on mobile.
- **Progress is stored in `localStorage`**, which is per-browser and per-origin.
  Clearing site data clears the profile. Settings -> Export / Import moves it.

### Hosting it

The output is static files — any static host works, and several are free:

| Host | Free |
| --- | --- |
| GitHub Pages | Yes — the repository is public |
| Cloudflare Pages | Yes |
| Netlify | Yes |
| Vercel | Yes |

Serve it from a subpath with `flutter build web --base-href /deutsch-garden/`.

## Installing a release

Every platform's build is attached to the
[latest release](https://github.com/Arman10121995/deutsch-garden/releases/latest),
while `release/README.md` points there. The binaries themselves are not copied
into Git: the APK alone is over GitHub's 100 MB per-file repository limit.

| Platform | Asset | Install |
| --- | --- | --- |
| Android | `DeutschGarden.apk` | Copy it to the phone and open it. Android asks you to allow installing from this source; that prompt is inherent to sideloading. The APK is signed with the project's release key, not a debug key — see `docs/SECURITY_WARNINGS.md`. |
| Windows | `DeutschGarden-windows-x64.zip` | Extract anywhere and run `DeutschGarden.exe`. SmartScreen will warn on first run: **More info → Run anyway**. |
| Linux | `DeutschGarden-x86_64.AppImage` | `chmod +x` it and run it. Self-contained apart from GTK 3, which every desktop distribution already ships. The `.tar.gz` is the same build unpacked, run `./bundle/DeutschGarden`. |
| macOS | `DeutschGarden-macos.zip` | Unzip and move to Applications. Gatekeeper blocks it on first open because it is not notarized: right-click → **Open**, or `xattr -dr com.apple.quarantine /Applications/DeutschGarden.app`. |
| iOS | `DeutschGarden-ios-unsigned.ipa` | **Unsigned.** It carries no provisioning profile, so it cannot be installed by tapping it. Re-sign it with your own certificate through Sideloadly or AltStore, or run `flutter build ipa` on your own Mac. |

Why each platform warns, and which warnings a certificate would remove, is in
[`SECURITY_WARNINGS.md`](SECURITY_WARNINGS.md).

The release also includes a signed `DeutschGarden.aab`. At 246 MiB in 4.5 it
is a reproducible app-bundle artifact inside Google Play's current 500 MB
compressed base-module limit. Play warns mobile-data users before downloads
over 200 MB, so an asset-pack split could improve acquisition, but it is not a
size prerequisite for upload. The GitHub APK remains the complete, fully
offline build.

## The bundled voices

Since 3.9 the app has shipped its own German voice rather than relying only on
whatever the operating system provides. Version 4.4 added a second one so a
dialogue can keep stable, audibly different speaker roles. Thorsten and Kerstin
are Piper VITS models; Windows, macOS, iOS and Linux run them on device through
sherpa-onnx (Apache-2.0). Both voice datasets are CC0 and the model repository
is MIT, so they are compatible with this app's licence — see
`assets/tts/MODEL_CARD` and `assets/tts/MODEL_CARD_KERSTIN`.

**Android is an intentional exception in 4.5.** Repeated device reproduction
found a native `SIGSEGV` inside `SherpaOnnxOfflineTtsGenerateWithConfig` while
rendering long programmes. Android therefore never initialises sherpa. It asks
the installed German system synthesiser to create each turn as a private WAV,
resamples and joins those turns with an 850 ms speaker gap, and plays the result
through Media3 ExoPlayer. This path was accepted on an API 36 device with a
2:52 radio programme: play, exact pause, ±10-second seeking, resume, stop and
cached replay all worked without killing the process. The app prefers voices
the OS marks offline; when only one usable voice exists it separates speakers
by pitch. No generated audio leaves the device when an offline voice is
installed.

Why bundle two models for something the OS already does:

- **Linux stops using espeak.** It was the worst audio in the app by a wide
  margin, and there was no better system option to fall back to.
- **Speaker roles stay distinct.** Narration uses Thorsten while the second
  character in a story, radio episode or role-play uses Kerstin on the four
  bundled-voice targets. Android selects distinct installed voices when it can
  and otherwise uses pitch separation.
- It is the groundwork for acoustic pronunciation scoring, which needs forced
  alignment from the same toolkit.

Practicalities:

- On the four sherpa targets, models are staged out of the asset bundle to the
  application support directory on first launch because sherpa-onnx opens real
  files. That work runs in the background after the first frame rather than on
  the first tap. Flutter's shared asset graph still places the model assets in
  Android packages, but Android does not load them; app size was explicitly
  accepted in favour of keeping one offline source tree.
- `espeak-ng-data` is trimmed to what German phonemisation needs — the core
  phoneme tables, `de_dict` and `lang/gmw/de`. Upstream ships dictionaries for
  roughly 120 languages at 18 MB; the subset is 733 KB and was verified to
  synthesise correctly before being adopted.
- The OS synthesiser remains the fallback on bundled-voice targets and is the
  primary Android implementation. It selects distinct installed voices where
  available and otherwise differentiates speakers by pitch.
- **The web build does not use them.** `dart:io` and real file paths do not exist
  there, so the browser speech synthesiser handles German through flutter_tts,
  selected by conditional import.
- Sherpa synthesis is synchronous native work, so it runs in a persistent
  worker isolate rather than freezing Flutter's UI. Android's platform-TTS WAV
  rendering is asynchronous. Both paths use stable cache names and reuse a
  completed programme on replay.

## Linux specifics

Recording needs `pulseaudio-utils` and `ffmpeg`:

```bash
sudo apt install pulseaudio-utils ffmpeg
```

Without them the pronunciation lab falls back to typed answers, which is what
Linux had before 3.17. With them it scores your pronunciation against the
bundled voice — Linux still has no speech recognition and therefore no
transcript, so it is the one platform that grades how you sounded without ever
knowing what you said.

Neither `flutter_tts` nor `speech_to_text` implements Linux; both declare
android, iOS, macOS, Windows and web only. So on Linux:

* **Speech synthesis** uses the bundled neural voice. If it cannot load,
  `lib/system_tts_io.dart` probes `spd-say` (speech-dispatcher), then
  `espeak-ng`, then `espeak`, and drives whichever answers. To install that
  fallback:

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
* adds `RECORD_AUDIO` and the TTS/speech-recognition package-visibility queries
  on Android, merging into Flutter's own `<queries>` block rather than replacing
  it; `INTERNET` exists only in Flutter's debug/profile manifests for the
  development service and is absent from the release manifest;
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
