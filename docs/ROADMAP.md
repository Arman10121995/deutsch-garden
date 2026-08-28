# Roadmap

Originally written after 3.5.0 and updated after the 3.11 engineering tranche.
For content sequencing and current numeric targets, use `UPGRADE_PLAN.md`.

## Honest verdict

This is a genuinely well-built project. The documentation is better than most
commercial software, the content is accurate German (a 60-entry sample across
A1–C2 turned up no wrong genders or plurals), `docs/KNOWN_LIMITATIONS.md` is
unusually candid, and the offline-first, no-account, five-platform-from-one-
codebase premise is a real differentiator rather than a slogan.

What held it back was not missing features. It was that **nothing verified the
things that were easy to get silently wrong**. The test suite did not compile,
so the CI gate was red and nobody knew. A corrupt profile was overwritten with a
blank one on the next frame. Release metadata was hand-maintained in five files
and had drifted by two minor versions. 222 of the app's lessons were never
scheduled for review. None of these are visible in a screenshot; all of them
matter more than another hundred vocabulary cards.

3.5.0 closed those. Later releases expanded the deck to 10,000 cards, added a
72-unit course, corpus-derived practice, a bundled neural voice and automated
multi-platform GitHub Releases. What follows is the remaining engineering work,
not a snapshot of the old content inventory.

## The three bets

### 1. Log individual reviews — the highest-leverage change available

Only aggregate state is stored: `WordProgress` and `ActivityProgress` hold a
current position, never a history. Nothing records that a card was graded
`Good` on a particular date at a particular interval.

That single absence blocks four separate things:

- **A better scheduler.** FSRS is fitted to review logs. Without logs, SM-2
  cannot be replaced, tuned, or even evaluated. `docs/KNOWN_LIMITATIONS.md` #12
  says the parameters are untuned; the real problem is that they are *untunable*.
- **Honest statistics.** "Accuracy 84%" over all time is nearly meaningless. A
  retention curve, a forecast of tomorrow's load, and true-retention-by-interval
  all need events.
- **Undo.** A misgrade is currently permanent.
- **Mergeable sync** (see bet 3). Two devices with event logs can reconcile;
  two devices with only current state can only overwrite each other.

Shape: an append-only list of `(itemId, timestamp, grade, intervalBefore,
easeBefore, elapsedDays)`, bounded at some tens of thousands of entries with the
oldest dropped. At ~40 bytes per event that is a few megabytes at the ceiling —
too much for the single SharedPreferences blob, which is the natural forcing
function for bet 2.

Do this first. Everything downstream of it is cheaper afterwards and impossible
before.

### 2. Move persistence off the single SharedPreferences key

The entire profile is one JSON string under one key, re-encoded and rewritten on
every answer — `_save()` is called from 21 sites in `lib/app_state.dart`. On
Android that is an XML file rewritten wholesale each time. 3.5.0 made a failed
read survivable (quarantine plus a last-known-good snapshot), but the underlying
shape is still wrong: one blob means one corruption event costs everything, and
an append-only review log cannot live in it at all.

`sqflite` covers Android, iOS, macOS, Windows and Linux; `drift` adds typed
queries on top. Either gives per-row writes, an events table, and no
all-or-nothing parse. The migration must be careful — read the old blob, write
the new store, keep the blob until the new store has been read back
successfully — but it is a well-trodden path.

Debouncing `_save()` is a worthwhile stopgap and takes an hour.

### 3. Make two devices reconcile instead of diverge

`docs/KNOWN_LIMITATIONS.md` #14 admits it: export/import is a whole-profile
overwrite, so studying on a phone and a laptop silently loses one side's work.
This is the only known limitation that actively destroys learner data.

No server is needed. Per-item last-write-wins over an event log merges correctly
for this data model: reviews are immutable facts with timestamps, and the
scheduler state is a pure function of them. A file exported to a folder the
learner already syncs, or a local-network transfer, is enough.

Depends on bet 1. Do not attempt it before there are events to merge.

### Runner-up, and why it loses

**User-added content** — paste any German text, mine sentences, import a word
list — would extend practice beyond the bundled 10,000-card deck, and it is
what LingQ and Readlang are for. It is still secondary, because arbitrary text needs
dictionary lookup for arbitrary words, and a bundled German dictionary of useful
coverage is 50–200 MB. That is a real decision about what the app is, not an
incremental feature. Revisit once the data layer can hold it.

## Remaining findings

### Correctness and data

| | Finding | Effort |
|---|---|---|
| High | No review event log. See bet 1. | weeks |
| High | Whole profile in one SharedPreferences key, rewritten per answer. See bet 2. | weeks |
| Done | `_save()` was called from 26 sites with no debounce, re-encoding and rewriting the whole profile per answer. Writes now coalesce over 500ms with a 5s ceiling, and flush on restore, on startup migration and on leaving the foreground. 3.24. | — |
| Done | Intervals are spread by up to five per cent from three days upward, so a session no longer clumps onto one day. 3.24. | — |
| Done | A late correct recall is credited: half the delay on `Good`, all of it on `Easy`, none on `Hard`, capped at 60 days. 3.24. | — |
| Low | `previewLabel` in `lib/srs.dart` calls `DateTime.now()` internally while `schedule()` takes an injectable clock — 22 `DateTime.now()` sites across `lib/` overall. A `Clock` abstraction would make streak and rollover logic testable across midnight and DST. | days |

### Pedagogy

| | Finding | Effort |
|---|---|---|
| High | Placement routes on 6 items per band at a 67% threshold. A learner whose true per-item probability sits near the boundary is close to a coin flip; the reported band carries no confidence interval. Either widen the bank or terminate on a confidence criterion. `lib/assessment.dart`. | days |
| Medium | Free-talk scoring counts length and connectives and cannot tell whether the content points were addressed (`docs/KNOWN_LIMITATIONS.md` #10). Authored content-point keyword sets with German stemming would close most of the gap offline. | days |
| Medium | A conservative 429-card lower-level rescue is complete, but the remaining deck has not had a card-by-card, sense-specific human CEFR audit. Continue re-levelling in reviewable tranches and preserve every judgement in a stable mapping. | weeks |

### Speech

| | Finding | Effort |
|---|---|---|
| High | Pronunciation scoring is text-based (`docs/KNOWN_LIMITATIONS.md` #6), Linux has no recogniser at all (#7), and Android may route audio to vendor servers (#9). A bundled offline ASR model addresses all three. `sherpa-onnx` is already present for synthesis; the remaining work is selecting a licence-compatible German ASR/alignment model and proving it on each native target. | months |
| Done | Piper/VITS neural German synthesis is bundled since 3.9 and runs off the UI isolate since 3.11, with the OS engine retained as fallback. | — |
| — | A bundled sub-1B LLM for the conversation tutor is **not** recommended. A model that generates wrong German in a teaching app is worse than a script that generates none. A richer authored branching dialogue graph is the better use of the same effort. | — |

### Product and reach

| | Finding | Effort |
|---|---|---|
| High | No reminders. The app has streaks, daily goals and rotating quests, and no notification of any kind — a daily-habit loop with no way to prompt the habit. `flutter_local_notifications` covers Android, iOS, macOS and Linux; Windows needs a separate path. Deliberately not attempted in 3.5.0 because it cannot be verified without real devices. | days |
| High | The UI is hardcoded English and every card's translation is English-only. The largest German-learning populations are Turkish, Arabic, Ukrainian, Russian and Syrian. Two distinct problems: extracting UI strings (mechanical) and making the translation language a data-model dimension (structural). | weeks |
| Medium | No onboarding. `INSTRUCTIONS.md` exists in the repo and is never surfaced in the app; a new learner lands on a roadmap with no guidance. | days |
| Medium | Store readiness beyond icons: signed AAB, privacy-policy URL, data-safety declaration, feature graphic, MSIX metadata and Apple signing/notarization. GitHub distribution is complete; store-specific packages are not. | days |
| Done | A `v*` tag builds all six targets, creates a GitHub Release and attaches eight artifacts. | — |

### Architecture

| | Finding | Effort |
|---|---|---|
| Medium | `AnimatedBuilder(animation: controller)` wraps the entire `MaterialApp` in `lib/app.dart`, so every `notifyListeners()` — 20 call sites — rebuilds the whole tree. Splitting `AppController` into focused notifiers would shrink the blast radius. Real, but not yet a measured problem. | weeks |
| Low | `lib/games.dart` is 2,545 lines and 14 screens; `skill_screens.dart` 1,648. Splitting by screen family is safe, mechanical, and improves nothing a user can see. | days |

## What not to do

- **Do not run `dart format` across the repo.** 44 of 52 files are unformatted,
  but `lib/vocabulary.dart` and `lib/vocabulary_expansion.dart` deliberately
  keep one card per line, which reads as a data table. Formatting would explode
  10,000 entries into hundreds of thousands of lines and destroy that. A format gate is not
  worth the trade; this is a case where the existing style is better than the
  tool's.
- **Do not memoize the `reviewWords` / `newWords` getters without measuring.**
  The real cost was building hundreds of card widgets
  per keystroke, which is fixed. Adding a cache here buys nothing and
  introduces invalidation bugs.
- **Do not add a state-management package** for its own sake. The god-object is
  a real issue; `provider`/`riverpod` is not automatically the answer, and a
  rewrite is not justified by a rebuild cost nobody has measured.
- **Do not chase vocabulary count as the headline metric.** The deck already
  contains 10,000 cards. Better sequencing, level review and connected practice
  now matter more than another round number.
- **Do not bundle a small LLM for the conversation tutor.** See above.

## Risk register

| Risk | Mitigation |
|---|---|
| A storage migration loses profiles | Write the new store, read it back, and only then retire the old blob. The quarantine and snapshot machinery from 3.5.0 stays in place throughout. |
| Content errors scale faster than review | Every mechanical property that can be checked should be checked in `tool/validate_content.py`, as the German quote rule now is. Human review does not scale; the validator does. |
| Bundled speech models bloat the app | App size is explicitly accepted. Keep licence provenance and per-platform performance as hard gates even when size is not one. |
| Scope explosion for one maintainer | The bets are ordered by dependency for a reason. Bet 1 is small and unlocks the rest. Resist starting bet 3 or the speech work first. |
| A1–C2 labels imply more precision than the evidence supports | Keep the vocabulary policy explicit, continue sense-specific manual re-levelling, and never describe the app's placement result as certification. |
