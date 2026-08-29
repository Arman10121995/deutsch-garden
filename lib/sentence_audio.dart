/// Reusable German sentence playback controls.
library;

import 'package:flutter/material.dart';

import 'tts_service.dart';

/// One shared synthesiser is enough for every small speaker button. A new TTS
/// object per list row would allocate an audio player for every visible card.
final TtsService _sentenceTts = TtsService();

class SentenceAudioButton extends StatelessWidget {
  const SentenceAudioButton({
    super.key,
    required this.text,
    required this.enabled,
    this.compact = true,
    this.rate = 1.0,
  });

  final String text;
  final bool enabled;
  final bool compact;
  final double rate;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? play = enabled && text.trim().isNotEmpty
        ? () => _sentenceTts.speakGerman(text, rate: rate)
        : null;
    if (compact) {
      return IconButton.filledTonal(
        tooltip: 'Listen to this sentence',
        onPressed: play,
        icon: const Icon(Icons.volume_up_rounded),
      );
    }
    return FilledButton.tonalIcon(
      onPressed: play,
      icon: const Icon(Icons.volume_up_rounded),
      label: const Text('Listen to sentence'),
    );
  }
}

/// Text plus a speaker control, laid out safely on both narrow phones and
/// desktop cards.
class SpeakableSentence extends StatelessWidget {
  const SpeakableSentence({
    super.key,
    required this.text,
    required this.enabled,
    this.textAlign = TextAlign.start,
    this.style,
  });

  final String text;
  final bool enabled;
  final TextAlign textAlign;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: Text(text, textAlign: textAlign, style: style)),
        const SizedBox(width: 8),
        SentenceAudioButton(text: text, enabled: enabled),
      ],
    );
  }
}
