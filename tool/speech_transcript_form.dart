/// Human verification controls for the private developer speech-capture tool.
library;

import 'package:flutter/material.dart';

import 'evaluate_speech.dart' as measurement;

class SpeechTranscriptForm extends StatelessWidget {
  const SpeechTranscriptForm({
    super.key,
    required this.readingText,
    required this.silence,
    required this.transcript,
    required this.busy,
    required this.reviewed,
    required this.onReviewed,
    required this.onSave,
  });

  final String readingText;
  final bool silence, busy, reviewed;
  final TextEditingController transcript;
  final ValueChanged<bool> onReviewed;
  final VoidCallback onSave;

  @override
  Widget build(
    BuildContext context,
  ) => ValueListenableBuilder<TextEditingValue>(
    valueListenable: transcript,
    builder: (context, value, _) {
      final hasTranscript = measurement.transcriptWords(value.text).isNotEmpty;
      final canReview = !busy && (silence || hasTranscript);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            silence
                ? 'Silence control — no spoken words expected.'
                : 'Requested reading text (not the recognizer output):',
          ),
          if (!silence) ...[
            const SizedBox(height: 8),
            SelectableText(
              readingText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: busy
                  ? null
                  : () {
                      transcript.text = readingText;
                      onReviewed(false);
                    },
              child: const Text('I said exactly the displayed sentence'),
            ),
            TextField(
              controller: transcript,
              enabled: !busy,
              minLines: 2,
              maxLines: 4,
              onChanged: (_) => onReviewed(false),
              decoration: InputDecoration(
                labelText: 'What I actually said',
                helperText: hasTranscript
                    ? 'Correct any omitted or different words, then confirm below.'
                    : 'Type your transcript, or use the exact-reading button above after listening.',
                helperMaxLines: 3,
              ),
            ),
          ],
          CheckboxListTile(
            value: reviewed,
            onChanged: canReview ? (v) => onReviewed(v ?? false) : null,
            title: Text(
              silence
                  ? 'I listened and confirm this is the intended silence control'
                  : 'I listened and confirm that the transcript matches my recording',
            ),
          ),
          FilledButton(
            onPressed: canReview && reviewed ? onSave : null,
            child: const Text('Save verified attempt and continue'),
          ),
        ],
      );
    },
  );
}
