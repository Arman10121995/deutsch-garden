# Speaking: how the tutor works

The Speak tab has three modes. All three run on the device and none of them
requires a network connection or an account.

## 1. Role-plays (`lib/conversation.dart`, `lib/conversation_screens.dart`)

A role-play is an authored sequence of turns. Each `DialogueStep` carries:

| Field | Purpose |
| --- | --- |
| `tutorGerman` / `tutorEnglish` | what the partner says, and its translation |
| `task` | what you have to achieve this turn, in English |
| `keywords` | any-of markers showing you addressed the turn |
| `requiredHits` | how many distinct markers a full-credit answer needs |
| `minWords` | authored length floor (see the invariant below) |
| `modelAnswer` | a correct answer, shown after two failed attempts |
| `quickReplies` | tappable starters for when you freeze |
| `coachTip` | the grammar or pragmatics point the turn practises |

You reply by microphone or by typing. The reply goes to
`ConversationEngine.evaluate`, which:

1. normalises the text (lower-case, umlaut/ß folding, punctuation stripped),
2. counts how many `keywords` it contains, with stem tolerance so `wohnen`
   matches *wohne*, *wohnst* and *gewohnt*,
3. checks the length against the step's effective minimum,
4. scores the turn at 75 % content / 25 % length,
5. accepts the turn if it hit `requiredHits` markers **and** met the length.

Fail a turn and you get a hint. Fail three times and the tutor shows the model
answer and moves on — nobody gets stuck on one line forever.

### The length invariant

`DialogueStep.effectiveMinWords` is `min(minWords, words(modelAnswer))`. A turn
must never demand more language than its own model answer contains, or the app
would be rejecting the sentence it presents as correct. This is enforced by a
test that runs every model answer through the evaluator; it caught three real
authoring bugs when it was added.

## 2. Free talk

No script. You get a question, the content points a complete answer should
cover, the connectors you should be reaching for, and a target length. Your
answer is scored 60 % on length against the target and 40 % on connector use,
then compared against a model answer.

This is an honest but blunt instrument: it measures *fluency volume and
discourse marking*, which is what an offline system can measure. It cannot tell
whether you actually addressed the content points. Treat the score as a fluency
gauge and the model answer as the real feedback.

## 3. Pronunciation lab (`lib/pronunciation.dart`)

Hear the model sentence, repeat it and compare the available feedback. The lab
is **ungraded** from 4.22: practice time counts, but finishing does not write a
pass/fail, graded XP, retention event or review schedule. Existing profile
history is retained.

Where recording is available, the bundled voice provides a synthetic reference.
The app shows approximate relative timing, without a percentage pronunciation
grade. MFCC/DTW distances remain diagnostic data in the private validation
runner; their synthetic mapping was invalidated by the physical Windows check.
Digital near-silence is rejected before normalisation can amplify microphone
hiss. Louder background noise can still pass this numerical input floor.

Where a transcript is available, a Needleman–Wunsch alignment highlights
recognised words as matched, close or missing and labels the percentage as
**recognised word agreement**. It describes the recogniser's output, not proof
of what the learner said or a judgement of an individual vowel. The optional
offline model can mishear learner German; installing it never creates a grade.

## Measuring speech feedback

A ten-attempt physical Windows capture/playback check is complete. Reference
and recorded playback were confirmed audible by the speaker. Its private corpus
contains speaker-verified transcripts and both wrong-sentence and silence
controls. This verifies the capture path on one PC and exposes defects; it does
not establish population accuracy or calibrate a learner pass mark.

See [SPEECH_VALIDATION.md](SPEECH_VALIDATION.md) for the collection protocol,
resumable native capture tool and local measurement runner. Independent blinded
ratings and representative held-out speakers/devices remain necessary before
restoring pronunciation grading. Unit-test tones verify the pipeline only.

## Speech recognition

`lib/speech_service.dart` wraps `speech_to_text`. It resolves a German locale at
startup, degrades gracefully when no recogniser or permission is available, and
reports *why* rather than leaving a dead button. Typed input is always available
and scores identically.
