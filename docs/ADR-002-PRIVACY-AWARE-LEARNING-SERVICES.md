# ADR 002: privacy-aware learning services

- **Status:** accepted
- **Release:** 4.4.0

## Context

DeutschGarden needs speech, reminders, optional downloads and useful learning
statistics, but remains account-free, MIT licensed and usable offline. Asking
for every device permission “just in case” would weaken that promise, increase
store-review risk and give the app access unrelated to teaching German.

The same release also needs dialogue speakers to sound distinct and study time
to remain accurate when routes nest, the app backgrounds or a session crosses
midnight.

## Decision

1. **Least privilege.** Notification access is requested only after the learner
   enables reminders. Microphone access is requested only from a speaking or
   pronunciation action. Location, calls, contacts, calendar, camera, broad file
   access and exact alarms are neither declared nor requested.
2. **Offline after an explicit download.** All ordinary content and two German
   voices ship in the app. The existing optional desktop ASR model remains the
   sole network path: named, sized, attributed and initiated by a button. The
   Android release keeps no `INTERNET` permission.
3. **A local interval ledger.** Educational routes open named intervals in
   `AppController`. A stack closes the parent while a nested activity is active,
   lifecycle events close work before background time, and calendar-day
   aggregation splits an interval at midnight. At most 2,000 intervals persist.
4. **Role-based speech.** Thorsten is narrator/speaker A and Kerstin is speaker
   B. Story quotations, role-play tutor turns and multi-speaker radio declare a
   role rather than selecting a model path themselves. Browser/native fallback
   voices preserve the same roles where possible.
5. **One reminder per day.** Six daily weekly-recurring slots cover Monday to
   Saturday. Sunday carries the combined daily/weekly target. Scheduling is
   local, time-zone aware and inexact; permission stays opt-in.

## Consequences

- Learners can inspect start/end times and daily/weekly minutes without an
  account, telemetry or cloud database.
- Dialogue is clearer at the cost of roughly another 63 MB in native bundles.
- Notification text reflects the last locally saved progress; without a server
  it cannot update while the app is closed, which is the intended trade.
- Features that genuinely need a new sensitive permission require a new
  decision rather than quietly expanding the manifest.
