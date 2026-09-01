# Engineering plan

Twenty items, ordered by dependency and by value per hour. This is the
working plan; `ROADMAP.md` is the reasoning behind it and `KNOWN_LIMITATIONS.md`
is the honest list of what the app still cannot do.

**Progress is not tracked in this file.** Run:

```bash
python tool/plan_status.py
```

It derives each item's state from the repository — a grep for the debounce
timer, for `sqflite` in `pubspec.yaml`, for a review-event class — so an item
cannot be marked done by editing prose. `python tool/plan_status.py next`
prints the next unfinished item.

The probes are shallow by design: they say the work landed, not that it is
correct. Each item below names the test that proves the behaviour, and those
live in `test/`.

---

## A. Scheduling quality

Independent of each other and of everything else, hours each. These change the
core loop for every learner, which is why they come first despite being small.

### A1 — Debounce profile writes

`_save()` is called from 26 sites in `lib/app_state.dart` with no debounce.
Every answer re-encodes the entire profile to JSON and rewrites it. On Android
that is a whole XML file per card.

**Done when** a short coalescing delay batches bursts into one write, a flush
happens on pause and on dispose so nothing is lost when the app is backgrounded
or killed, and no caller has to know about any of it.

**Proved by** a test that issues many mutations and asserts one write, plus one
that asserts a pending write is flushed on lifecycle pause.

### A2 — Fuzz review intervals

Every card graded in one session comes due on exactly the same later day, so
the queue clumps into peaks instead of levelling out. Anki randomises by a few
per cent for this reason.

**Done when** intervals of three days or more are spread by a small percentage,
the spread is driven by an injectable source so tests are deterministic, and
the grade-button preview still shows the honest unfuzzed number.

**Proved by** a test that schedules the same card many times with a seeded
source and asserts the results spread without drifting the mean.

### A3 — Credit overdue reviews

A card answered `Good` thirty days late is scheduled as though it were answered
on the due date. The extra elapsed time is evidence of retention and is
currently thrown away.

**Done when** `schedule()` accepts when the card was actually due and folds the
lateness into the next interval on the SM-2 terms Anki uses — half the delay on
`Good`, all of it on `Easy`, none on `Hard`.

**Proved by** a test that an on-time and a thirty-days-late `Good` produce
different intervals, and that the late one is longer.

---

## B. The data layer

Strictly ordered. Each unlocks the next, and B3 is impossible before B1.

### B1 — Append-only review event log

The single highest-leverage change available. Only aggregate state is stored;
nothing records that a card was graded `Good` on a date at an interval. That
one absence blocks a tuned scheduler, honest retention statistics, undo of a
misgrade, and any merge that is not an overwrite.

**Done when** each review appends `(itemId, timestamp, grade, intervalBefore,
easeBefore, elapsedDays)` to a bounded log that drops the oldest entries at its
ceiling, and the log survives a save/load round trip.

The log is capability, not a feature: **B4** and **B5** are what a learner
actually sees from it, and neither was possible before.

### B2 — Profile off the single SharedPreferences key

The whole profile is one JSON string under one key. One corruption event costs
everything, and B1's log cannot live in it.

**Done, with the scope stated.** `sqflite` holds the review log in its own
table, a row per event, appended as it happens and uncapped. The migration
reads the blob's log, writes the table, **reads it back and counts it**, and
only then lets the profile stop carrying it; anything that fails leaves the
blob exactly as it was.

Two things deliberately did not move:

*The profile core stays in SharedPreferences.* It is 761 bytes with a
quarantine-and-snapshot recovery path built over several releases. Moving that
buys nothing measurable now that writes are debounced, and a bug in the move
costs a learner every review they have ever done. The log was 175 KB of the
176 KB blob — moving it is where all the benefit was.

*Web keeps the log in the profile, still capped.* SQLite has no web
implementation, and putting a learner's only history under an experimental
IndexedDB build is not a trade worth making. `reviewLogIsExternal` reports
which case a platform is in.

### B3 — Reconcile two devices instead of overwriting

**Done.** Import defaults to an offline, item-by-item merge over the review
event log. Duplicate events collapse, the newer review of the same item controls
its scheduler state, untouched progress from both copies survives, and the
current device's theme, reminder and accessibility settings remain local. A
deliberate whole-profile replacement is still available behind an explicit
choice.

### B4 — Undo a misgrade

A misgrade is permanent: the answer overwrote the scheduler state and nothing
remembered what it had been. B1 changed that — each event carries the interval
and ease the card was on before the answer — so the previous state can now be
reconstructed.

**Done when** the last review of an item can be reverted, and reverting also
removes the event so it cannot be counted twice.

### B5 — Retention statistics from the log

"Accuracy 84%" over all time answers almost nothing. With events there can be
a real answer: true retention by interval bucket, reviews due per day ahead,
and how often a card at a given interval is actually recalled.

**Done when** retention is computed from the log rather than from running
totals, and the figure states the window it covers.

---

## C. Habit and reach

### C1 — Study reminders
**Done on platforms where a reliable local scheduler exists.** Android, iOS and
macOS offer one opt-in notification per day at a learner-chosen time. The app
asks permission only when enabled, includes the live due count, and uses the
device's IANA time zone so the wall time survives DST and travel. Web, Linux and
Windows explain that scheduled reminders are unavailable rather than exposing a
switch that cannot work.

### C2 — In-app onboarding
A new learner lands on a route screen with nothing explained. `ROADMAP.md`
suggested surfacing `INSTRUCTIONS.md`, but that file is a build guide for
whoever compiles the app -- `flutter analyze`, `bootstrap.ps1` -- and showing
it to a learner would be worse than showing nothing. This needed writing, not
surfacing.

**Done when** a first run explains what the app is, that it is offline and
account-free, that progress is local and worth exporting, and what Learn does;
it can be skipped; and it is shown exactly once.

### C3 — Localise the interface
**Infrastructure done, migration begun and explicitly unfinished.**

`flutter_localizations` and generated ARB strings are wired in, English and
German both ship, and the learner can pick either or follow the device from
Profile → Settings. The shell, the first-run intro and the settings heading
read from the translations; `tool/check_l10n.py` fails the build when a key
exists in one locale and not the other, or when placeholders disagree —
the first falls back silently, the second throws at runtime in the locale
the author does not use.

**What is not done:** roughly 450 further chrome strings across the game,
skill, test and course screens. The `MIGRATED` list in `tool/check_l10n.py`
names the files that are finished, so the boundary is checked rather than
remembered, and a migrated file that grows a new hardcoded string fails.

Deliberately not translated: the ten thousand cards, the stories, the grammar
tables and the conversation scenarios. That is the German being taught, not
interface text. A few interface strings — *Verstanden*, *Los geht's* — stay
German in every locale for the same reason.

### C4 — Translations in languages other than English
**Mechanism done; one language shipped, partially.**

The card model keeps its English gloss as a field, because ten thousand const
entries are a readable data table worth keeping. A second language is a side
table instead: one JSON asset per language keyed by card id, resolved at
lookup, falling back to the card's English. Adding a language is a data drop
and one line in `pubspec.yaml` — it touches no Dart.

Turkish ships, covering **478 of 10,000 cards (4.8%)**: exactly the concrete
nouns that already carry a drawing. That set was chosen because those are the
words a picture could be made of, which is the same property that makes a
one-word translation safe. Abstract cards are left to English rather than
given a Turkish word that narrows a meaning the English was careful about.

The gloss language is deliberately separate from the interface language.
A Turkish speaker living in Germany may want the app in German and the
glosses in Turkish, and neither choice drags the other with it.

`tool/check_glosses.py` verifies every id is a real card, nothing is blank,
and no entry is still the German word — with deliberate loanwords
(*Park*, *Balkon*, *Pizza*) recorded line by line in
`tool/gloss_cognates.tsv` rather than the rule loosened.

**What it cannot check is whether *elma* is the right word for *Apfel*.**
These glosses have not been reviewed by a native speaker; that is recorded in
`docs/KNOWN_LIMITATIONS.md` rather than implied away by a green build.
Arabic, Ukrainian and Russian are not started.

---

## D. Correctness and pedagogy

### D1 — Injectable clock
32 `DateTime.now()` sites across `lib/`. Streak and day-rollover logic cannot
be tested across midnight or a DST boundary without this.

### D2 — Terminate placement on confidence
Six items per band at a 67% threshold. A learner near a boundary is close to a
coin flip and the reported band carries no interval.

### D3 — Score free talk on content points
Scoring counts length and connectives, so an off-topic answer of the right
length scores well. Authored keyword sets with German stemming close most of
the gap offline.

---

## E. Store packaging

GitHub distribution is complete. The store-specific extras:

**E1 — signed Android App Bundle.** Done and proved in CI: Play accepts only
an AAB, a phone installs only an APK, and both now come from the same signed
configuration. The bundle's signature is checked by jarsigner's exit code and
certificate name.

**E2 — Windows MSIX.** Done and proved in CI. Self-signed, so SmartScreen
still prompts; what it buys over the zip is a Start-menu entry, clean
uninstall and per-user install without administrator rights. The zip stays,
because an MSIX from an untrusted publisher is *harder* to run than a folder.

**E3 — signed and notarised macOS build.** The pipeline is written and gated
on four repository secrets, in the same shape as the Android keystore: absent,
it warns and ships the unsigned build; present, it imports the certificate,
signs with the hardened runtime, submits to notarytool and staples the ticket.

**It has never executed, because it needs a paid Apple Developer account the
project does not have.** Treat the tracker's tick as "the pipeline is ready",
not "a notarised build exists". Adding `APPLE_CERTIFICATE_P12_BASE64`,
`APPLE_CERTIFICATE_PASSWORD`, `APPLE_SIGNING_IDENTITY`, `APPLE_ID`,
`APPLE_TEAM_ID` and `APPLE_APP_SPECIFIC_PASSWORD` is the whole remaining
change.

---

## F. Long-running

### F1 — Offline speech recognition
Addresses three known limitations at once: text-based pronunciation scoring,
no recogniser on Linux, and Android possibly routing audio to vendor servers.
`sherpa-onnx` is already bundled for synthesis.

**Done in 4.1, as an optional desktop download — with one thing still
unmeasured, and shipped in a shape that survives it being bad.**

Three decisions, each of which could have gone the other way:

**Which model.** NVIDIA `stt_de_fastconformer_hybrid_large_pc`, int8, as
repackaged by k2-fsa. CC-BY-4.0 — attribution required, which composes with
MIT exactly as the Tabler icons do. The 55 MB Kroko alternative was rejected:
CC-BY-SA with non-commercial free keys, and share-alike inside an MIT
application is a compliance burden with no upside. The size objection that
deferred this in 3.17 had already expired; `docs/UPGRADE_PLAN.md` item 17
carries the measured table.

**Not bundled.** At the time of this decision, the App Bundle was 184 MB against
Play's then-current 200 MB cap. Adding 105 MB would have traded the ability to
publish for a feature most learners never switch on. Google raised that cap to
500 MB in July 2026, but the product decision still stands: the recogniser is an
optional desktop feature, so it downloads once, on request, by name, with the
size stated before the button — and then works offline forever. That is the only
use the third rule of `docs/ASSET_POLICY.md` has ever been put to.

**Desktop only, and this is the interesting one.** The model runs fine on a
phone. What stops it is that `tool/patch_android_manifest.py` strips the
INTERNET permission, so on Android the offline promise is enforced by the
operating system rather than by anyone remembering. Restoring that permission
for every learner — most of whom will never open this setting — to serve an
opt-in extra, on a platform that already has a system recogniser, is not the
minimal use the policy asks for. Linux, which has no recogniser at all, is the
platform that actually gains. macOS gets `com.apple.security.network.client`
and the MSIX gets `internetClient`, because a download button that fails
silently inside a sandbox is worse than one that is not offered.

**What is still not measured, and how the design survives that.** Nobody has
run this model against learner German. NVIDIA's 5.1% word error rate is
Common Voice — native read speech. So the transcript is not allowed to be the
verdict: the acoustic score of 3.17 stays the primary number, the word
breakdown appears beside it labelled as a second opinion, and its score is
deliberately not averaged into the recorded activity score. A learner whose
accent it reads badly can switch the transcript off and keep the model. If the
measurement ever comes back bad, nothing has to be withdrawn — see
`docs/KNOWN_LIMITATIONS.md` #18.

`tool/check_network_use.py` holds the whole bargain in place: one file may
open a socket, only to the k2-fsa releases, the licence and the accuracy
caveat must keep travelling with the model, Android must not regain INTERNET,
and no analytics or crash-reporting dependency may appear. Each of those five
was proved by reintroducing the violation and watching the build fail.

### F2 — Card-by-card CEFR re-levelling audit
**Done: every card in the deck now carries a recorded judgement.**

`tool/cefr_relevelling.tsv` has 10,000 rows and is authoritative;
`apply_relevelling.py` writes them into the deck and `check_relevelling.py`
fails the build when the two disagree. That gate is the point — the levels
drifted because they were set in bulk, and the next bulk edit would otherwise
undo every decision silently.

Two bases, never conflated:

- **hand (23).** Someone read the card. These win over anything derived.
- **corpus (9,977).** Derived by `tool/cefr_evidence.py` from the level of the
  bundled material that uses the word. The stories, radio episodes and
  role-plays were each *written* for a stated level, so the words inside them
  are evidence the bulk import never had.

**The derived method was validated before being trusted**: run against the 23
cards a person had already read, it reproduces 22 of them. The one difference
is *Grad* — hand says A2, corpus says A1 — and the hand row wins, which is
what the basis column is for.

It is deliberately conservative. A word must appear at least twice in a
level's material to count, tokens under four characters are ignored as
function words and code noise, and a card may fall at most two bands on
derived evidence so one stray appearance cannot drag a C2 word to A1. 346
cards moved; 8,527 have no bundled material using them at all and are recorded
as "no evidence", level unchanged.

**What this is not:** a human reading 10,000 cards. 9,977 rows say `corpus`
precisely so that nobody later mistakes the audit for something it was not.
Promoting those to `hand` is the remaining work, and the file makes it
resumable a tranche at a time.

---

## Explicitly not doing

Carried from `ROADMAP.md`, because the reasons still hold: no repo-wide
`dart format` (it would explode the one-card-per-line vocabulary tables), no
memoising the review getters without a measurement, no state-management package
for its own sake, no chasing card count past 10,000, and no bundled small LLM
for the conversation tutor — a model that generates wrong German in a teaching
app is worse than a script that generates none.
