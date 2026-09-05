import 'package:deutsch_garden/dialogue_audio.dart';
import 'package:deutsch_garden/neural_voice.dart';
import 'package:deutsch_garden/tts_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('role-play scripts', () {
    test('ordinary role-play alternates between two voices', () {
      final List<SpokenTurn> turns = alternatingDialogueTurns(<String>[
        'Guten Morgen.',
        'Hallo!',
        'Wie geht es Ihnen?',
      ]);
      expect(turns.map((SpokenTurn t) => t.voice), <GermanVoiceRole>[
        GermanVoiceRole.speakerA,
        GermanVoiceRole.speakerB,
        GermanVoiceRole.speakerA,
      ]);
    });

    test('the cast wraps rather than running out', () {
      final List<SpokenTurn> turns = alternatingDialogueTurns(
        List<String>.generate(6, (int i) => 'Zeile $i'),
      );
      final List<GermanVoiceRole> roles = turns
          .map((SpokenTurn t) => t.voice)
          .toList();
      expect(roles, <GermanVoiceRole>[
        GermanVoiceRole.speakerA,
        GermanVoiceRole.speakerB,
        GermanVoiceRole.speakerA,
        GermanVoiceRole.speakerB,
        GermanVoiceRole.speakerA,
        GermanVoiceRole.speakerB,
      ]);
    });

    test('no character is ever given the narrator voice', () {
      // The narrator is the one voice a listener has to be able to tell apart
      // from everybody in the scene.
      final List<SpokenTurn> turns = alternatingDialogueTurns(
        List<String>.generate(9, (int i) => 'Zeile $i'),
      );
      expect(
        turns.map((SpokenTurn t) => t.voice),
        isNot(contains(GermanVoiceRole.narrator)),
      );
    });
  });

  group('labelled scripts', () {
    test('the same name keeps the same voice throughout', () {
      // Alternation cannot do this: it hands out voices by position, so a
      // person who speaks twice in a row changes voice mid-scene.
      final List<SpokenTurn> turns = labelledDialogueTurns(<String>[
        'Anna: Guten Morgen.',
        'Ben: Hallo Anna.',
        'Anna: Wie geht es dir?',
        'Clara: Da seid ihr ja!',
        'Ben: Gut, danke.',
      ]);
      final Map<String, GermanVoiceRole> byText = <String, GermanVoiceRole>{
        for (final SpokenTurn t in turns) t.text: t.voice,
      };
      expect(byText['Guten Morgen.'], byText['Wie geht es dir?']);
      expect(byText['Hallo Anna.'], byText['Gut, danke.']);
      expect(byText['Guten Morgen.'], isNot(byText['Hallo Anna.']));
      expect(
        byText['Da seid ihr ja!'],
        isNot(anyOf(byText['Guten Morgen.'], byText['Hallo Anna.'])),
      );
    });

    test('an unlabelled line continues the speaker before it', () {
      // A two-line speech belongs to one person; splitting it between two
      // voices is worse than not attributing it at all.
      final List<SpokenTurn> turns = labelledDialogueTurns(<String>[
        'Anna: Guten Morgen.',
        'Ich habe lange geschlafen.',
      ]);
      expect(turns, hasLength(2));
      expect(turns[1].voice, turns[0].voice);
    });

    test('a line before anyone has spoken is narration', () {
      final List<SpokenTurn> turns = labelledDialogueTurns(<String>[
        'Es war früh am Morgen.',
        'Anna: Guten Morgen.',
      ]);
      expect(turns.first.voice, GermanVoiceRole.narrator);
      expect(turns.last.voice, isNot(GermanVoiceRole.narrator));
    });

    test('a stray colon does not invent a speaker', () {
      // "Er sagte: ..." is narration with a colon in it, not a labelled line
      // by a person called "Er sagte". The label has to be short and
      // name-shaped, which is what the length bound is for.
      final List<SpokenTurn> turns = labelledDialogueTurns(<String>[
        'Am Bahnhof gab es nur eine einzige wirklich lange Durchsage: '
            'der Zug fiel aus.',
      ]);
      expect(turns.single.voice, GermanVoiceRole.narrator);
    });
  });

  group('stories', () {
    test('narration and each quoted speaker differ', () {
      final List<SpokenTurn> turns = storySpokenTurns(<String>[
        'Mia öffnet die Tür. „Guten Morgen“, sagt sie.',
        'Tom antwortet: „Hallo Mia!“',
      ]);
      expect(
        turns.map((SpokenTurn t) => t.voice),
        containsAllInOrder(<GermanVoiceRole>[
          GermanVoiceRole.narrator,
          GermanVoiceRole.speakerA,
          GermanVoiceRole.narrator,
          GermanVoiceRole.speakerB,
        ]),
      );
      expect(
        turns.map((SpokenTurn t) => t.text).join(' '),
        contains('Guten Morgen'),
      );
    });

    test('line-based stories keep quote alternation across lines', () {
      final List<SpokenTurn> turns =
          storyTurnsFromLines(<({String german, GermanVoiceRole? voice})>[
            (german: '„Guten Morgen.“', voice: null),
            (german: '„Hallo!“', voice: null),
            (german: '„Wie geht es dir?“', voice: null),
          ]);
      expect(
        turns
            .where((SpokenTurn turn) => turn.voice != GermanVoiceRole.narrator)
            .map((SpokenTurn turn) => turn.voice),
        <GermanVoiceRole>[
          GermanVoiceRole.speakerA,
          GermanVoiceRole.speakerB,
          GermanVoiceRole.speakerA,
        ],
      );
    });
  });

  group('the mapping to bundled voices', () {
    test('every role has a voice, and they are all different', () {
      final Set<NeuralVoice> voices = <NeuralVoice>{
        for (final GermanVoiceRole role in GermanVoiceRole.values)
          neuralVoiceForRole(role),
      };
      expect(voices, hasLength(GermanVoiceRole.values.length));
    });

    test('the narrator is not one of the character voices', () {
      expect(
        neuralCharacterVoices,
        isNot(contains(neuralVoiceForRole(GermanVoiceRole.narrator))),
      );
    });

    test('every bundled voice names a real asset and a model card', () {
      // A voice whose files are missing is a voice that crashes the isolate
      // the first time somebody plays a dialogue.
      for (final NeuralVoice voice in NeuralVoice.values) {
        final NeuralVoiceAssets assets = neuralVoiceAssets[voice]!;
        expect(assets.model, isNotEmpty, reason: voice.name);
        expect(assets.tokens, isNotEmpty, reason: voice.name);
        expect(assets.card, isNotEmpty, reason: voice.name);
        expect(assets.person, isNotEmpty, reason: voice.name);
        expect(assets.sampleRate, greaterThan(0), reason: voice.name);
      }
      expect(
        neuralVoiceAssets.values.map((NeuralVoiceAssets a) => a.person).toSet(),
        hasLength(NeuralVoice.values.length),
        reason: 'five voices must be five different people',
      );
    });
  });
}
