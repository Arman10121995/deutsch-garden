import 'package:deutsch_garden/tts_service.dart';
import 'package:deutsch_garden/voice_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('role pitch stays distinct when the engine has one voice', () {
    expect(
      GermanVoiceRole.values
          .map((GermanVoiceRole role) => germanPitchForRole(role.index))
          .toSet(),
      hasLength(GermanVoiceRole.values.length),
    );
  });

  test('voice attempts are stable and cover rejected slots', () {
    expect(germanVoiceAttemptOrder(GermanVoiceRole.speakerB.index, 3), <int>[
      2,
      0,
      1,
    ]);
    expect(germanVoiceAttemptOrder(GermanVoiceRole.speakerD.index, 0), isEmpty);
  });

  test('a thrown voice and a rejected voice do not end the dialogue', () async {
    final List<String> attempted = <String>[];
    final bool selected = await selectGermanVoice(
      roleIndex: 1,
      voices: <Map<String, String>>[
        <String, String>{'name': 'available'},
        <String, String>{'name': 'missing'},
        <String, String>{'name': 'refused'},
      ],
      setVoice: (Map<String, String> voice) async {
        final String name = voice['name']!;
        attempted.add(name);
        if (name == 'missing') throw StateError('Voice not installed');
        return name == 'available' ? 1 : 0;
      },
    );
    expect(selected, isTrue);
    expect(attempted, <String>['missing', 'refused', 'available']);
  });

  test('all rejected voices allow the caller to use pitch fallback', () async {
    var attempts = 0;
    expect(
      await selectGermanVoice(
        roleIndex: 4,
        voices: <Map<String, String>>[
          <String, String>{'name': 'missing'},
        ],
        setVoice: (_) async {
          attempts++;
          throw StateError('Voice not installed');
        },
      ),
      isFalse,
    );
    expect(attempts, 1);
  });
}
