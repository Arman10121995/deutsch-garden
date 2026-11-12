# The answer loop in 4.24

4.24 changes what happens in the few seconds around an answer. It adds no
cards, lessons or screens. The vocabulary session is the activity every learner
does most, and an audit of it as a first-time learner found four things that
made each answer worth less than it should have been.

## What was wrong

1. **The wrong options gave the answer away.** They were drawn at random from
   the whole level. *der Mann* was offered beside "to allow; to permit",
   "sadly" and a preposition, so the only noun was the answer and the question
   was solved by word class without recalling anything.
2. **An answer was not shown.** All four options were disabled together. The
   learner could not see which one they had picked or which was right without
   reading a sentence below. The lesson quizzes did tint two options, but by
   colour alone.
3. **A missed word was gone until another day.** Being shown the right answer
   is not the same as producing it. The scheduler has a one-minute relearning
   step precisely so a lapsed card is retrieved again in the same sitting, and
   the session never asked.
4. **The way forward was off screen.** A new-word card is taller than a phone,
   so "Got it — test me" started below the fold on every card. On a desktop
   every answer needed the mouse.

## Wrong options

`lib/quiz_distractors.dart` picks the three wrong options. It prefers, in
order: the same word class in the same deck topic (at most two of these, so a
small topic does not produce the same neighbours every time), the same word
class, then the rest of the topic, then anything. Adjectives and the deck's
"adjective or adverb" entries count as one class.

No two options show the same text, and none repeats the answer. When the
options are German words, a card with the same meaning as the target is
excluded too: a synonym would be a second right answer.

Word class is the existing `wordClassFor` inference from article and gloss. It
is a heuristic, not a tagged lexicon, so an occasional option of another class
is possible; see `KNOWN_LIMITATIONS.md` #24. The article question is unchanged:
its options are always der, die and das.

## Showing the answer

`lib/answer_option.dart` is one option button, shared by the vocabulary session
and the grammar, listening and reading quizzes. After an answer:

| Option | Mark | Tint |
| --- | --- | --- |
| The right answer | Tick | Green |
| The learner's wrong pick | Cross | Error colour |
| Any other | None | Disabled |

The tick and the cross carry the meaning; the tint only reinforces it. Each
mark has a spoken label ("Correct answer", "Your answer") for a screen reader.

The vocabulary feedback panel now shows the verdict with the same mark, the
card's example sentence with its speaker button and translation, and, where
the prompt was in the learner's language, a button to hear the word. Lesson
quizzes state the verdict above the explanation: "Correct." or "Not quite.
Correct answer: …".

## Second try

A word answered wrongly is asked once more after everything else in the
sitting, in the same direction, with freshly chosen options. It is labelled
"Second try". The feedback for the first miss says it will return.

- It is graded like any other answer. A correct second try is the `Good` on a
  relearning card that the scheduler already expects; nothing about the
  schedule was changed.
- A second miss is not queued a third time. The card is already due and the
  sitting has to end.
- A skipped word is not queued. Skipping is the learner declining the item.
- Previous still undoes the last answer exactly. Undoing a wrong answer also
  withdraws the second try it queued.
- The session summary lists each word missed at least once under "Worth
  another look", including one recalled on its second try.

The progress bar counts queued second tries, so it can step back slightly after
a miss. Session accuracy counts every graded answer, second tries included.

## Keyboard and layout

- **1–4** choose an option (1–3 for articles, and however many a lesson
  question has). The numeric keypad works too.
- **Enter or Space** continues after an answer and moves on from a new-word
  card. They are only taken while no button or field has the focus, so a
  learner tabbing to a speaker button and pressing Enter still gets the
  speaker.
- A typed answer keeps every key, and its field takes the focus without a tap.
- Desktop builds show a one-line reminder of the keys under the options.
- The session's primary button sits in a fixed bar under the scrolling card.

The same number and Enter keys work in grammar, listening and reading quizzes.

## Learn

The streak and XP counters at the top of Learn were emoji beside a number. They
are now icons from the bundled icon font with a tooltip that names the number,
so they do not depend on the platform having a colour-emoji font. Below them a
slim bar shows today's goal ("Today 7/20", then "Daily goal reached"), which
was previously inside a collapsed card at the bottom of the page.

## What did not change

- The SM-2 scheduler, its parameters, XP values, mistake-bank entries and
  review log format.
- The order of a learn session: each new word is still shown and then tested
  before the next. Introducing words in small groups before testing them would
  be better retrieval practice and is not done here.
- Smart review (the reveal-and-grade flashcards), the games, civics, driving,
  placement and exam screens. Their answer feedback is their own.
- Any card, gloss, example sentence or lesson text.

## Verification

`test/learning_loop_test.dart` covers the selection rule against the real deck
(every eleventh card at every level gets three distinct wrong options in both
directions; nouns sit beside nouns and verbs beside verbs), synonym exclusion,
small word classes, option marks and their spoken labels, the second try and
its single repeat, undo withdrawing a queued second try, the summary list, the
keyboard in both the session and a lesson quiz, the fixed action bar at 320
pixels, and the Learn counters and daily goal.
