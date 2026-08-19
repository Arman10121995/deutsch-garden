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

You hear a model sentence, repeat it, and the recognised transcript is aligned
against the target with a Needleman–Wunsch pass (substitution cost = 1 −
character similarity, insertion/deletion cost = 1). Each target word comes back
as matched, close or missing, and is coloured accordingly.

Extra words cost 0.35 rather than 1.0, because recognisers routinely emit filler
tokens and punishing those makes the score feel arbitrary.

### What this can and cannot detect

It **detects**: dropped words, inserted words, wrong words, wrong endings, wrong
word order, and mis-stressed compounds that the recogniser hears as two words.

It **cannot detect**: a single mispronounced vowel or consonant in a word the
recogniser still transcribes correctly. Phoneme-level scoring needs forced
alignment against an acoustic model, which no offline Flutter plugin provides.
The lab says this on screen rather than implying a precision it does not have.

## Speech recognition

`lib/speech_service.dart` wraps `speech_to_text`. It resolves a German locale at
startup, degrades gracefully when no recogniser or permission is available, and
reports *why* rather than leaving a dead button. Typed input is always available
and scores identically.
