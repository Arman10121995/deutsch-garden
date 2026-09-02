/// The two bundled, fully offline German neural voices.
enum NeuralVoice { thorsten, kerstin }

/// One item in a seekable, multi-speaker neural-audio programme.
class NeuralTurn {
  const NeuralTurn(this.text, {required this.voice});

  final String text;
  final NeuralVoice voice;
}
