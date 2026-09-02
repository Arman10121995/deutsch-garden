import 'package:deutsch_garden/speech_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all recognizer end states are terminal', () {
    expect(isTerminalSpeechStatus('done'), isTrue);
    expect(isTerminalSpeechStatus('notListening'), isTrue);
    expect(isTerminalSpeechStatus('doneNoResult'), isTrue);
    expect(isTerminalSpeechStatus(' listening '), isFalse);
  });
}
