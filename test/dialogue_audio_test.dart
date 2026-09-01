import 'package:deutsch_garden/dialogue_audio.dart';
import 'package:deutsch_garden/tts_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dialogue lines alternate two stable speaker roles', () {
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

  test('story narration and quoted speech use different voices', () {
    final List<SpokenTurn> turns = storySpokenTurns(<String>[
      'Mia öffnet die Tür. „Guten Morgen“, sagt sie.',
      'Tom antwortet: „Hallo Mia!“',
    ]);
    expect(
      turns.map((SpokenTurn t) => t.voice),
      containsAllInOrder(<GermanVoiceRole>[
        GermanVoiceRole.narrator,
        GermanVoiceRole.speakerB,
        GermanVoiceRole.narrator,
        GermanVoiceRole.speakerA,
      ]),
    );
    expect(
      turns.map((SpokenTurn t) => t.text).join(' '),
      contains('Guten Morgen'),
    );
  });
}
