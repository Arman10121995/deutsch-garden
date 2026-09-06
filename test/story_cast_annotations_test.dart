import 'package:deutsch_garden/stories.dart';
import 'package:deutsch_garden/tts_service.dart';
import 'package:flutter_test/flutter_test.dart';

final RegExp _quotedText = RegExp(r'„[^“]+“|“[^”]+”|"[^"]+"');

int _quoteCount(String text) => _quotedText.allMatches(text).length;

void main() {
  test('every legacy quoted StoryLine has explicit quote metadata', () {
    for (final Story story in stories) {
      for (final StoryChapter chapter in story.chapters) {
        for (final StoryLine line in chapter.lines) {
          if (line.voice != null) continue;
          expect(
            line.quotedVoices,
            hasLength(_quoteCount(line.german)),
            reason: '${story.id}/${chapter.id}: ${line.german}',
          );
        }
      }
    }
  });

  test('one speaker stays stable for adjacent and cross-chapter quotes', () {
    final Story aylaStory = stories.firstWhere((Story s) => s.id == 'st-a2-02');
    final StoryLine shouted = aylaStory.chapters[0].lines.firstWhere(
      (StoryLine line) => line.german.startsWith('„Der Topf!'),
    );
    expect(shouted.quotedVoices, <GermanVoiceRole>[
      GermanVoiceRole.speakerB,
      GermanVoiceRole.speakerB,
    ]);
    expect(
      shouted.spokenTurns.where(
        (SpokenTurn t) => t.voice == GermanVoiceRole.speakerB,
      ),
      hasLength(2),
    );

    final Story amirStory = stories.firstWhere((Story s) => s.id == 'st-a1-01');
    final StoryLine amirIntro = amirStory.chapters[0].lines.firstWhere(
      (StoryLine line) => line.german.startsWith('„Entschuldigung'),
    );
    final StoryLine amirGreeting = amirStory.chapters[2].lines.firstWhere(
      (StoryLine line) => line.german.startsWith('„Ich heiße Amir'),
    );
    expect(amirIntro.quotedVoices, <GermanVoiceRole>[GermanVoiceRole.speakerA]);
    expect(amirGreeting.quotedVoices, <GermanVoiceRole>[
      GermanVoiceRole.speakerA,
    ]);
    final neighbourLines = amirStory.chapters[2].lines.where(
      (line) =>
          line.german.contains('Nachbar, Bernd') ||
          line.german.contains('Willkommen! Trinken'),
    );
    expect(neighbourLines, hasLength(2));
    for (final line in neighbourLines) {
      expect(line.quotedVoices, <GermanVoiceRole>[GermanVoiceRole.speakerC]);
    }
    final landlord = amirStory.chapters[1].lines.firstWhere(
      (line) => line.german.contains('Hier ist der Schlüssel'),
    );
    expect(landlord.quotedVoices, <GermanVoiceRole>[GermanVoiceRole.speakerD]);
  });
}
