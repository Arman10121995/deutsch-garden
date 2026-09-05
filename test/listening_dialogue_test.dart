import 'package:deutsch_garden/curriculum.dart';
import 'package:deutsch_garden/dialogue_audio.dart';
import 'package:deutsch_garden/tts_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bakery customer and seller keep their own voice', () {
    final lesson = listeningLessons.firstWhere(
      (lesson) => lesson.id == 'li-a1-01',
    );
    final turns = labelledDialogueTurns(lesson.transcript.split('\n'));
    expect(turns.map((turn) => turn.voice), <GermanVoiceRole>[
      GermanVoiceRole.speakerA,
      GermanVoiceRole.speakerB,
      GermanVoiceRole.speakerA,
      GermanVoiceRole.speakerB,
    ]);
    expect(turns.first.text, startsWith('Guten Morgen.'));
    expect(turns.last.text, 'Das macht vier Euro zwanzig.');
    expect(lesson.translation.split('\n'), hasLength(turns.length));
  });

  test('colleague introduction has two speakers; announcement has one', () {
    final colleagues = listeningLessons.firstWhere(
      (lesson) => lesson.id == 'li-a1-02',
    );
    expect(
      labelledDialogueTurns(
        colleagues.transcript.split('\n'),
      ).map((turn) => turn.voice).toSet(),
      hasLength(2),
    );
    final announcement = listeningLessons.firstWhere(
      (lesson) => lesson.id == 'li-a1-03',
    );
    expect(
      labelledDialogueTurns(announcement.transcript.split('\n')).single.voice,
      GermanVoiceRole.narrator,
    );
  });
}
