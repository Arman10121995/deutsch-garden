import 'package:deutsch_garden/conversation.dart';
import 'package:deutsch_garden/conversation_engine.dart';
import 'package:deutsch_garden/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sixty authored role-plays, plus the story interviews on top', () {
    // Counted apart on purpose. A story interview is a guided oral retelling
    // of a reader, derived from a story rather than written as a situation to
    // speak into, and for a while the two were reported as one number of 60 --
    // which read as sixty situations and was twenty-three of them.
    final authored = conversationScenarios
        .where((scenario) => !scenario.id.startsWith('cv-story-'))
        .toList();
    final interviews = conversationScenarios
        .where((scenario) => scenario.id.startsWith('cv-story-'))
        .toList();

    expect(authored, hasLength(60), reason: 'authored role-plays');
    expect(interviews, hasLength(storyInterviewTarget));
    expect(conversationScenarios, hasLength(60 + storyInterviewTarget));

    // Every level gets a real share of the authored ones rather than the
    // total being propped up at one level.
    for (final level in CefrLevel.values) {
      final atLevel = authored.where((s) => s.level == level);
      expect(atLevel.length, greaterThanOrEqualTo(6),
          reason: '${level.label} has only ${atLevel.length} authored '
              'role-plays');
    }
  });

  test('every level ships role-plays and free-talk prompts', () {
    for (final CefrLevel level in CefrLevel.values) {
      expect(
        conversationsFor(level),
        isNotEmpty,
        reason: '${level.label} has no role-play',
      );
      expect(
        freeTalkFor(level),
        isNotEmpty,
        reason: '${level.label} has no free-talk prompt',
      );
    }
  });

  test('scenario ids are unique and every step is answerable', () {
    final Set<String> ids = <String>{};
    for (final ConversationScenario scenario in conversationScenarios) {
      expect(ids.add(scenario.id), isTrue, reason: 'duplicate ${scenario.id}');
      expect(scenario.steps, isNotEmpty);
      for (final DialogueStep step in scenario.steps) {
        expect(step.tutorGerman.trim(), isNotEmpty);
        expect(
          step.keywords,
          isNotEmpty,
          reason: '${scenario.id} has an unscorable step',
        );
        expect(
          step.requiredHits,
          lessThanOrEqualTo(step.keywords.length),
          reason: '${scenario.id} demands more keywords than it defines',
        );
        expect(step.modelAnswer.trim(), isNotEmpty);
      }
    }
  });

  test('the model answer always passes its own step', () {
    // Collected rather than asserted per step, so one run reports every
    // mismatched keyword list instead of only the first.
    final List<String> failures = <String>[];
    for (final ConversationScenario scenario in conversationScenarios) {
      for (int i = 0; i < scenario.steps.length; i++) {
        final DialogueStep step = scenario.steps[i];
        final TurnEvaluation evaluation = ConversationEngine.evaluate(
          step,
          step.modelAnswer,
        );
        if (!evaluation.accepted) {
          failures.add(
            '${scenario.id} step ${i + 1}: matched '
            '${evaluation.matched.length}/${step.requiredHits} keywords, '
            'tooShort=${evaluation.tooShort} — "${step.modelAnswer}"',
          );
        }
      }
    }
    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  test('an empty or off-topic answer is rejected', () {
    final DialogueStep step = conversationScenarios.first.steps.first;
    expect(ConversationEngine.evaluate(step, '').accepted, isFalse);
    expect(
      ConversationEngine.evaluate(step, 'blablabla xyzzy quux').accepted,
      isFalse,
    );
  });

  test(
    'a too-short answer with the right content is flagged, not failed hard',
    () {
      const DialogueStep step = DialogueStep(
        tutorGerman: 'Erzähl mir von deiner Arbeit.',
        tutorEnglish: 'Tell me about your work.',
        task: 'Describe your job.',
        keywords: <String>['arbeite'],
        minWords: 8,
        modelAnswer: 'Ich arbeite seit drei Jahren als Ingenieur in Rostock.',
        modelAnswerEnglish:
            'I have worked as an engineer in Rostock for three years.',
      );
      final TurnEvaluation evaluation = ConversationEngine.evaluate(
        step,
        'Ich arbeite.',
      );
      expect(evaluation.accepted, isFalse);
      expect(evaluation.tooShort, isTrue);
      expect(evaluation.matched, contains('arbeite'));
      expect(evaluation.score, greaterThan(0));
    },
  );

  test('keyword matching tolerates German inflection', () {
    const DialogueStep step = DialogueStep(
      tutorGerman: 'Wo wohnst du?',
      tutorEnglish: 'Where do you live?',
      task: 'Say where you live.',
      keywords: <String>['wohnen'],
      minWords: 2,
      modelAnswer: 'Ich wohne in Rostock.',
      modelAnswerEnglish: 'I live in Rostock.',
    );
    expect(
      ConversationEngine.evaluate(step, 'Ich wohne in Rostock.').accepted,
      isTrue,
    );
  });

  test('the model answer scores well on its free-talk prompt', () {
    for (final FreeTalkPrompt prompt in freeTalkPrompts) {
      final FreeTalkEvaluation evaluation = ConversationEngine.evaluateFreeTalk(
        prompt,
        prompt.modelAnswer,
      );
      expect(
        evaluation.score,
        greaterThanOrEqualTo(60),
        reason: '${prompt.id} model answer only scored ${evaluation.score}',
      );
    }
  });

  test('a one-word free-talk answer scores badly and is coached', () {
    final FreeTalkPrompt prompt = freeTalkPrompts.first;
    final FreeTalkEvaluation evaluation = ConversationEngine.evaluateFreeTalk(
      prompt,
      'Ja.',
    );
    expect(evaluation.score, lessThan(30));
    expect(evaluation.tips, isNotEmpty);
  });

  test('session score is the mean of its turns', () {
    expect(ConversationEngine.sessionScore(const <TurnEvaluation>[]), 0);
  });
}
