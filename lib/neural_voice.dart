/// The bundled, fully offline German neural voices.
///
/// There are five because a conversation can have more than two people in it.
/// Until 4.8 there were two, and the mapping was worse than that number
/// suggests: the narrator and the first speaker were the *same* voice, so a
/// story read aloud had its narrator and one of its characters sounding
/// identical, and a three-way dialogue collapsed to two voices with one person
/// silently doubled.
///
/// Every voice here is a genuinely different person, and every one carries a
/// licence this project can actually honour. That second constraint did most
/// of the choosing: the German voices with the best audio -- `dii-high` and
/// `miro-high` at 22 kHz -- are CC BY-NC-SA and say "commercial use is not
/// allowed", which an app on three storefronts cannot use, and `pavoque` is
/// the same. What is left is CC0 and BSD-3-Clause, and four of the five are
/// 16 kHz as a result.
///
/// That trade is deliberate and was made explicitly: a second *person* is
/// worth more to a dialogue than a higher sample rate on a doubled one. The
/// renderer resamples mixed rates, so the cast can be mixed freely.
library;

/// A bundled speaker.
///
/// The order matters: [narrator] is the default for anything unattributed, and
/// the rest are handed out in order as a dialogue needs them.
enum NeuralVoice {
  /// Thorsten. The narrator, and the only voice at 22.05 kHz.
  narrator,

  /// Kerstin.
  speakerA,

  /// Karlsson.
  speakerB,

  /// Eva K.
  speakerC,

  /// Ramona.
  speakerD,
}

/// What a voice needs in order to be loaded.
class NeuralVoiceAssets {
  const NeuralVoiceAssets({
    required this.model,
    required this.tokens,
    required this.card,
    required this.person,
    required this.sampleRate,
  });

  /// File name inside `assets/tts/`.
  final String model;
  final String tokens;

  /// The model card that has to travel with it. CC0 asks for nothing, but
  /// M-AILABS is BSD-3-Clause and requires the notice to be retained.
  final String card;

  /// Who this is, for attribution and for the settings screen.
  final String person;

  final int sampleRate;
}

/// The roster, in [NeuralVoice] order.
const Map<NeuralVoice, NeuralVoiceAssets> neuralVoiceAssets =
    <NeuralVoice, NeuralVoiceAssets>{
  NeuralVoice.narrator: NeuralVoiceAssets(
    model: 'de_DE-thorsten-medium.onnx',
    tokens: 'tokens.txt',
    card: 'MODEL_CARD',
    person: 'Thorsten',
    sampleRate: 22050,
  ),
  NeuralVoice.speakerA: NeuralVoiceAssets(
    model: 'de_DE-kerstin-low.onnx',
    tokens: 'tokens-kerstin.txt',
    card: 'MODEL_CARD_KERSTIN',
    person: 'Kerstin',
    sampleRate: 16000,
  ),
  NeuralVoice.speakerB: NeuralVoiceAssets(
    model: 'de_DE-karlsson-low.onnx',
    tokens: 'tokens-karlsson.txt',
    card: 'MODEL_CARD_KARLSSON',
    person: 'Karlsson',
    sampleRate: 16000,
  ),
  NeuralVoice.speakerC: NeuralVoiceAssets(
    model: 'de_DE-eva_k-x_low.onnx',
    tokens: 'tokens-eva_k.txt',
    card: 'MODEL_CARD_EVA_K',
    person: 'Eva K',
    sampleRate: 16000,
  ),
  NeuralVoice.speakerD: NeuralVoiceAssets(
    model: 'de_DE-ramona-low.onnx',
    tokens: 'tokens-ramona.txt',
    card: 'MODEL_CARD_RAMONA',
    person: 'Ramona',
    sampleRate: 16000,
  ),
};

/// The character voices, narrator excluded, in the order they are handed out.
const List<NeuralVoice> neuralCharacterVoices = <NeuralVoice>[
  NeuralVoice.speakerA,
  NeuralVoice.speakerB,
  NeuralVoice.speakerC,
  NeuralVoice.speakerD,
];

/// The voice for the *n*th distinct character in a piece of dialogue.
///
/// Wraps once the cast runs out, which is the honest failure: a sixth speaker
/// shares a voice with the first rather than falling back to the narrator,
/// because the narrator is the one voice a listener must always be able to
/// tell apart from the characters.
NeuralVoice neuralVoiceForSpeaker(int index) =>
    neuralCharacterVoices[index % neuralCharacterVoices.length];

/// One item in a seekable, multi-speaker neural-audio programme.
class NeuralTurn {
  const NeuralTurn(this.text, {required this.voice});

  final String text;
  final NeuralVoice voice;
}
