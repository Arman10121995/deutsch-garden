# Privacy

DeutschGarden 4.4 is a local-first, account-free application on Android,
Windows, macOS, iOS, Linux and web.

## Stored locally

- vocabulary and lesson scheduling state;
- an append-only review history used for undo and retention statistics;
- learner-written mnemonics and writing drafts;
- activity scores, role-play/story progress and the capped mistake bank;
- XP, streak, daily counters, quests and achievement acknowledgements;
- theme, audio, interface/gloss language, reminder and daily-goal settings;
- placement and civics-test progress.
- a capped study-time ledger containing the activity label and local start/end
  timestamps used for the learner's own daily and weekly statistics.

The compact profile lives in platform preferences. Native builds keep the
larger review-event history in a local SQLite table; web keeps a bounded copy in
the profile because it has no supported SQLite implementation. The bundled
voice is copied from the application package into application support on first
use because the speech engine requires normal files.

**Settings → Reset all learning progress** clears learner state. Uninstalling
the application removes its private application storage under normal platform
behaviour.

## Spoken input

The pronunciation lab records one local WAV for acoustic comparison with the
bundled reference voice. The clip is deleted immediately after scoring, after a
cancelled recording, or when an empty attempt is detected. It is never uploaded
or added to a learner profile or backup.

Platform speech recognition is a separate optional path:

- Android, iOS/macOS and Windows may provide a system recogniser;
- Linux and web use typed input where a supported recogniser is unavailable;
- a mobile operating-system recogniser may itself contact its vendor unless an
  offline German language pack is installed.

That vendor behaviour belongs to the operating-system service, not to a
DeutschGarden server. The Android application itself has no `INTERNET`
permission and cannot make network requests. Every speaking screen accepts
typed input, and the microphone is unused until the learner starts it.

## Text to speech

Native builds synthesise German locally with the bundled CC0 Thorsten and
Kerstin voices. Dialogue and quoted speech alternate voices so speaker changes
are audible. The operating-system voice is a fallback if the bundled engine
cannot start.
Web uses the browser's speech-synthesis service, whose implementation is
controlled by that browser.

## What leaves the device

The source contains no analytics SDK, advertising SDK, account system, remote
database integration or DeutschGarden server.

**Settings → Export progress** puts the complete portable profile on the
clipboard as plain text. That is the one app operation that can move learner
data off the device, and it happens only after an explicit press and only to
wherever the learner pastes it. Import defaults to a safe offline merge; it does
not transmit either copy.

## Permissions

- `RECORD_AUDIO` / Apple microphone entitlements — requested only for speaking
  or pronunciation features.
- Apple speech-recognition usage description — required before an Apple system
  recogniser can be used.
- `POST_NOTIFICATIONS` on Android 13+ — requested only when the learner enables
  opt-in daily/weekly target reminders. Reminders are scheduled locally.
- `RECEIVE_BOOT_COMPLETED` on Android — allows an already-enabled local reminder
  to be restored after reboot; it provides no network access.
- There is deliberately no Android `INTERNET` permission and no exact-alarm
  permission.
- Location, calls, contacts, calendar, camera and broad file access are not
  declared or requested. Speaker playback does not require a permission.
