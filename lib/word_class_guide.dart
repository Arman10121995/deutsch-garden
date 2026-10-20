/// A compact guide to the grammatical labels shown on every vocabulary card.
library;

import 'package:flutter/material.dart';

import 'gender_guide.dart';
import 'l10n/app_localizations.dart';
import 'curriculum_text.dart';
import 'models.dart';
import 'vocabulary.dart';
import 'vocabulary_metadata.dart';

class WordClassGuideScreen extends StatelessWidget {
  const WordClassGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<GermanWordClass, List<GermanWord>> groups =
        <GermanWordClass, List<GermanWord>>{
          for (final GermanWordClass wordClass in GermanWordClass.values)
            wordClass: <GermanWord>[],
        };
    for (final GermanWord word in vocabulary) {
      groups[word.wordClass]!.add(word);
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppText.of(context).wordClassGuide)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: <Widget>[
          Text(
            AppText.of(context).guideWordClassQuestion,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(AppText.of(context).guideWordClassIntro),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.abc_rounded),
              title: Text(AppText.of(context).guideGenderLink),
              subtitle: Text(AppText.of(context).guideGenderLinkBody),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const GenderGuideScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final GermanWordClass wordClass in GermanWordClass.values)
            if (groups[wordClass]!.isNotEmpty)
              Card(
                child: ExpansionTile(
                  leading: CircleAvatar(
                    child: Text(
                      curriculumText(AppText.of(context), wordClass.shortLabel),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  title: Text(
                    curriculumText(AppText.of(context), wordClass.label),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    AppText.of(
                      context,
                    ).guideCardCount(groups[wordClass]!.length),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        curriculumText(
                          AppText.of(context),
                          wordClass.learningNote,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: <Widget>[
                          for (final GermanWord word in groups[wordClass]!.take(
                            5,
                          ))
                            Chip(label: Text(word.displayGerman)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
