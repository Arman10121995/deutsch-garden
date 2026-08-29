# Roadmap

Originally written after 3.5.0 and updated through the 3.24 engineering
tranche. For executable current status run `python tool/plan_status.py`; for
content sequencing and numeric targets, use `UPGRADE_PLAN.md`.

The three bets below are retained as the rationale for the architecture. They
all shipped in 3.24: review events are logged, the large log lives outside the
profile blob on native platforms, and exported profiles merge item by item.

## Honest verdict

This is a genuinely well-built project. The documentation is better than most
commercial software, the content is accurate German (a 60-entry sample across
A1–C2 turned up no wrong genders or plurals), `docs/KNOWN_LIMITATIONS.md` is
unusually candid, and the offline-first, no-account, six-platform-from-one-
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
| Done | Review events now form an append-only history used by undo and true-retention statistics. 3.24. | — |
| Done | Native review history moved to SQLite after a verified migration; the compact recoverable profile remains in SharedPreferences and writes are debounced. 3.24. | — |
| Done | `_save()` was called from 26 sites with no debounce, re-encoding and rewriting the whole profile per answer. Writes now coalesce over 500ms with a 5s ceiling, and flush on restore, on startup migration and on leaving the foreground. 3.24. | — |
| Done | Intervals are spread by up to five per cent from three days upward, so a session no longer clumps onto one day. 3.24. | — |
| Done | A late correct recall is credited: half the delay on `Good`, all of it on `Easy`, none on `Hard`, capped at 60 days. 3.24. | — |
| Done | Calendar-sensitive scheduling and rollover logic read an injectable clock and are tested across boundaries. 3.24. | — |

### Pedagogy

| | Finding | Effort |
|---|---|---|
| Done | Placement uses reserve items and an 80% Wilson confidence interval around the 67% decision boundary, and reports uncertainty when ten items still cannot separate it. 3.24. | — |
| Done | Free-talk prompts carry authored content-point keyword sets matched with German-aware stemming; the UI reports missed points and the documented semantic limits remain. 3.24. | — |
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
| Done | One opt-in local daily reminder ships on Android, iOS and macOS with real-zone scheduling; unsupported targets say so explicitly. 3.24. | — |
| In progress | English/German localisation infrastructure and the first migrated interface surfaces ship, plus a side-table gloss mechanism and 478 Turkish concrete-noun meanings. Broad UI/content translation remains editorial work. | weeks |
| Done | A first-run flow explains the offline/account-free model, Learn and progress export exactly once and can be skipped. 3.24. | — |
| In progress | Signed APK/AAB and Windows zip/MSIX ship; the Apple signing/notarisation pipeline is ready but cannot execute without paid Apple credentials. Store listing assets and submissions remain account work. | days |
| Done | A `v*` tag builds all six targets, creates a GitHub Release and attaches ten artifacts. | — |

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
