import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'question_language_data.dart';

/// Offered after practice feedback, never a hint to a live mock's answer.
class QuestionLanguageTip extends StatelessWidget {
  const QuestionLanguageTip({super.key, required this.question});
  final String question;
  @override
  Widget build(BuildContext context) {
    final hint = questionLanguageHintFor(question);
    if (hint == null) return const SizedBox.shrink();
    final t = AppText.of(context);
    final german = t.localeName.startsWith('de');
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: ExpansionTile(
        leading: const Icon(Icons.lightbulb_outline_rounded),
        title: Text(t.questionGermanTip),
        subtitle: Text(hint.phrase),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(german ? hint.german : hint.english),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              hint.exampleGerman,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (!german) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(hint.exampleEnglish),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(t.questionGermanRecall),
          ),
        ],
      ),
    );
  }
}
