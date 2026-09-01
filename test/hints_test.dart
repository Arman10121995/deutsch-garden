import 'package:deutsch_garden/curriculum.dart';
import 'package:deutsch_garden/hints.dart';
import 'package:deutsch_garden/models.dart';
import 'package:flutter_test/flutter_test.dart';

ChoiceQuestion q({
  required List<String> options,
  int correct = 0,
  String prompt = 'Choose one.',
  String explanation = 'because.',
}) => ChoiceQuestion(
  prompt: prompt,
  options: options,
  correctIndex: correct,
  explanation: explanation,
);

void main() {
  group('the invariant', () {
    test('a hint never contains the answer', () {
      // The whole point. A hint that names the right option is not help, it
      // is the answer with extra steps, and the exercise stops measuring
      // anything.
      final ChoiceQuestion question = q(
        options: <String>['den', 'der', 'dem', 'des'],
      );
      final Hint? hint = hintForChoice(
        question,
        ruleText: 'Masculine accusative uses den.',
      );
      expect(hint, isNotNull);
      expect(hint!.text.toLowerCase(), isNot(contains('den ')));
      expect(
        hint.kind,
        HintKind.structural,
        reason:
            'the rule text named the answer, so it must be dropped in '
            'favour of the weaker structural hint',
      );
    });

    test('leak detection folds case and umlauts', () {
      expect(leaksAnswer('The answer is GRÜN.', 'grün'), isTrue);
      expect(
        leaksAnswer('Use the word Gruen', 'grün'),
        isFalse,
        reason: 'ue is a different spelling, not a fold this claims to do',
      );
      expect(
        leaksAnswer('Denken Sie nach.', 'den'),
        isFalse,
        reason: 'den inside denken is not a leak; whole words only',
      );
      expect(leaksAnswer('Nimm den Bus.', 'den'), isTrue);
      expect(leaksAnswer('anything', ''), isFalse);
    });

    test('a multi-word answer is caught as a phrase', () {
      expect(
        leaksAnswer(
          'Remember that sich interessieren für takes an accusative.',
          'sich interessieren für',
        ),
        isTrue,
      );
    });

    test('the rule is used when it does not give the game away', () {
      final Hint? hint = hintForChoice(
        q(
          options: <String>[
            'Ich lerne Deutsch.',
            'Ich Deutsch lerne.',
            'Ich lernen Deutsch.',
            'Lerne ich Deutsch.',
          ],
        ),
        ruleText: 'In a normal statement the finite verb sits in position two.',
      );
      expect(hint, isNotNull);
      expect(hint!.kind, HintKind.rule);
      expect(hint.text, contains('position two'));
    });
  });

  group('structural hints', () {
    test('an article question is told to think about case and gender', () {
      final Hint? hint = hintForChoice(
        q(options: <String>['der', 'die', 'das', 'dem']),
      );
      expect(hint, isNotNull);
      expect(hint!.kind, HintKind.structural);
      expect(hint.text, contains('case'));
    });

    test('a word-order question is told to find the finite verb', () {
      final Hint? hint = hintForChoice(
        q(
          options: <String>[
            'Ich glaube, dass er heute kommt.',
            'Ich glaube, dass er kommt heute.',
            'Ich glaube, dass kommt er heute.',
            'Ich glaube, dass heute er kommt.',
          ],
        ),
      );
      expect(hint, isNotNull);
      expect(hint!.text.toLowerCase(), contains('finite verb'));
    });

    test(
      'time, place and reason prompts receive question-specific guidance',
      () {
        expect(
          hintForChoice(
            q(
              prompt: 'Wann fährt der Zug?',
              options: <String>['Um acht.', 'In Berlin.'],
            ),
          )?.text,
          contains('time'),
        );
        expect(
          hintForChoice(
            q(
              prompt: 'Wohin fährt Mia?',
              options: <String>['Nach Köln.', 'Am Montag.'],
            ),
          )?.text,
          contains('destination'),
        );
        expect(
          hintForChoice(
            q(
              prompt: 'Warum bleibt er zu Hause?',
              options: <String>['Weil er krank ist.', 'Im Wohnzimmer.'],
            ),
          )?.text,
          contains('reason'),
        );
      },
    );
  });

  group('personalized progressive hints', () {
    final ChoiceQuestion question = q(
      prompt: 'Wann beginnt der Kurs?',
      options: <String>['Um neun.', 'Im Sprachzentrum.', 'Mit Anna.'],
    );

    test('a skipped item starts with a personalized nudge', () {
      final List<Hint> hints = hintsForChoice(
        question,
        personalization: const HintPersonalization(
          priorAttempts: 1,
          wasSkipped: true,
        ),
      );
      expect(hints, isNotEmpty);
      expect(hints.first.personalized, isTrue);
      expect(hints.first.text, contains('skipped'));
      expect(leaksAnswer(hints.first.text, 'Um neun.'), isFalse);
    });

    test('a prior wrong choice is named without leaking the answer', () {
      final List<Hint> hints = hintsForChoice(
        question,
        personalization: const HintPersonalization(
          priorAttempts: 1,
          priorWrongAnswer: 'Im Sprachzentrum.',
        ),
      );
      expect(hints.first.text, contains('Im Sprachzentrum'));
      expect(hints.first.personalized, isTrue);
      expect(leaksAnswer(hints.first.text, 'Um neun.'), isFalse);
    });

    test('mistake history is built for one stable question id', () {
      final HintPersonalization history =
          personalizationForQuestion(<MistakeEntry>[
            MistakeEntry(
              id: 'lesson-q2',
              prompt: 'Prompt',
              correctAnswer: 'Right',
              givenAnswer: 'Skipped',
              source: 'Grammar',
              level: 'A1',
              timestamp: DateTime(2026),
            ),
            MistakeEntry(
              id: 'other-q0',
              prompt: 'Other',
              correctAnswer: 'Right',
              givenAnswer: 'Wrong',
              source: 'Grammar',
              level: 'A1',
              timestamp: DateTime(2026),
            ),
          ], 'lesson-q2');
      expect(history.priorAttempts, 1);
      expect(history.wasSkipped, isTrue);
    });
  });

  group('vocabulary hints', () {
    const GermanWord word = GermanWord(
      id: 'x1',
      article: 'der',
      german: 'Bahnhof',
      plural: 'Bahnhöfe',
      english: 'train station',
      exampleGerman: 'Der Bahnhof ist groß.',
      exampleEnglish: 'The train station is big.',
      category: 'Travel',
      level: 'A1',
    );

    test('names the gender and category without naming the word', () {
      final Hint? hint = hintForWord(word, answer: 'train station');
      expect(hint, isNotNull);
      expect(hint!.text, contains('masculine'));
      expect(hint.text.toLowerCase(), contains('travel'));
      expect(leaksAnswer(hint.text, 'train station'), isFalse);
    });

    test('the example sentence is masked, including inflected forms', () {
      final Hint? hint = hintForWord(word, answer: 'Bahnhof');
      expect(hint, isNotNull);
      expect(hint!.text, contains('___'));
      expect(hint.text, isNot(contains('Bahnhof')));
    });

    test('masking catches a form the word does not literally take', () {
      // German inflects. An example for gehen says geht, and a mask that only
      // removed the exact lemma would leave the answer sitting in plain view
      // while looking like it had been hidden.
      const GermanWord verb = GermanWord(
        id: 'x2',
        article: '',
        german: 'gehen',
        plural: '',
        english: 'to go',
        exampleGerman: 'Er geht nach Hause.',
        exampleEnglish: 'He goes home.',
        category: 'Actions',
        level: 'A1',
      );
      final Hint? hint = hintForWord(verb, answer: 'gehen');
      expect(hint, isNotNull);
      expect(hint!.text, isNot(contains('geht')));
      expect(hint.text, contains('___'));
    });

    test('a learner mnemonic is the first progressive word hint', () {
      final List<Hint> hints = hintsForWord(
        word,
        answer: 'Bahnhof',
        personalization: const HintPersonalization(
          mnemonic: 'Picture the station clock.',
          lapses: 2,
        ),
      );
      expect(hints.first.personalized, isTrue);
      expect(hints.first.text, contains('station clock'));
      expect(
        hints.any((Hint hint) => hint.text.contains('missed this 2 times')),
        isTrue,
      );
    });
  });

  group('every grammar lesson in the app', () {
    test('produces a hint that does not answer its own question', () {
      // The real content, not a fixture. This is the assertion that would
      // actually catch a lesson whose explanation quotes its answer.
      int checked = 0;
      for (final GrammarLesson lesson in grammarLessons) {
        for (final ChoiceQuestion question in lesson.questions) {
          final Hint? hint = hintForChoice(
            question,
            ruleText: lesson.explanation,
          );
          if (hint == null) continue;
          checked += 1;
          final String answer = question.options[question.correctIndex];
          expect(
            leaksAnswer(hint.text, answer),
            isFalse,
            reason: '${lesson.id} hint gives away "$answer": ${hint.text}',
          );
        }
      }
      expect(checked, greaterThan(0), reason: 'nothing was actually checked');
    });

    test('most questions get a hint at all', () {
      int withHint = 0;
      int total = 0;
      for (final GrammarLesson lesson in grammarLessons) {
        for (final ChoiceQuestion question in lesson.questions) {
          total += 1;
          if (hintForChoice(question, ruleText: lesson.explanation) != null) {
            withHint += 1;
          }
        }
      }
      expect(total, greaterThan(0));
      // A help button that is usually absent is worse than none: the learner
      // stops looking for it.
      expect(
        withHint / total,
        greaterThan(0.9),
        reason: 'only $withHint of $total questions offer a hint',
      );
    });
  });
}
