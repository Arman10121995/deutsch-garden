# Privacy

DeutschGarden 3.2 is a local-first app on all five platforms it ships for.

## Stored locally

- vocabulary scheduling state (ease, interval, repetitions, lapses, due date)
- learner-written mnemonics
- activity best scores and attempts, including role-plays and story chapters
- writing drafts
- the mistake bank (capped at the 200 most recent entries)
- XP, streak, daily counters, quest completion and achievement acknowledgements
- theme, TTS, immersion-mode and daily-goal settings
- most recent placement result

All of it lives in `SharedPreferences` on the device and is removed by
**Settings → Reset all learning progress**.

## What leaves the device

The source contains no analytics SDK, advertising SDK, user account system or
remote database integration. There is no DeutschGarden server.

Two platform services are used, and both are worth understanding:

- **Text to speech.** Pronunciation is requested through the device TTS layer.
  The actual voice depends on the device and the installed TTS provider.
- **Speech recognition.** The microphone features call the platform recogniser
  (`android.speech.SpeechRecognizer` on Android, the Speech framework on
  iOS/macOS, the Windows speech API). Linux has none, so speaking practice
  there is typed-only.
  **On Android this may transmit audio to the platform vendor's servers** unless
  a German offline language pack is installed on the device. That is a property
  of the platform recogniser, not of this app, and this app cannot change it.
  Nothing is sent to any DeutschGarden endpoint, because none exists.

If that trade-off is unacceptable, every speaking screen accepts typed input
instead, and the microphone is never used unless you press it.

## Export and import

**Settings → Export progress** puts your entire local profile on the clipboard
as plain text. That is the one operation in the app that can move your data off
the device, and it happens only when you press it and only to wherever you
paste it. Nothing is transmitted by the app itself.

## Permissions

- `RECORD_AUDIO` (Android) / `NSMicrophoneUsageDescription` (iOS, macOS) /
  `com.apple.security.device.audio-input` (macOS sandbox) — requested only
  while a speaking screen is actively listening.
- `NSSpeechRecognitionUsageDescription` (iOS, macOS) — required by the OS
  before speech recognition may be used at all.
- `INTERNET` (Android) — required by the platform speech recogniser when it
  falls back to a network service. No other feature uses it, and the app makes
  no network requests of its own on any platform.
- Linux and Windows desktop builds request nothing beyond ordinary file access
  for their own settings.
