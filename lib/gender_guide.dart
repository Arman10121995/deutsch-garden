/// Der/die/das reference grouped by noun ending.
library;

import 'package:flutter/material.dart';

import 'models.dart';
import 'vocabulary.dart';
import 'vocabulary_metadata.dart';

class GenderGuideScreen extends StatelessWidget {
  const GenderGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> counts = <String, int>{
      for (final String article in <String>['der', 'die', 'das'])
        article: vocabulary
            .where((GermanWord word) => word.article == article)
            .length,
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Der, die, das guide')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: <Widget>[
          Text(
            'Learn a noun as one unit',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Article + noun + plural is the vocabulary item. Endings can '
            'provide useful clues, but meaning, origin and exceptions mean '
            'that no ending system replaces learning the article.',
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              _GenderCount(article: 'der', count: counts['der']!),
              const SizedBox(width: 8),
              _GenderCount(article: 'die', count: counts['die']!),
              const SizedBox(width: 8),
              _GenderCount(article: 'das', count: counts['das']!),
            ],
          ),
          const SizedBox(height: 20),
          for (final NounGender gender in NounGender.values) ...<Widget>[
            Text(
              '${gender.article.toUpperCase()} · ${gender.label}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final GenderEndingRule rule in genderEndingRules
                .where((GenderEndingRule rule) => rule.gender == gender)) ...<Widget>[
              _RuleCard(rule: rule),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 14),
          ],
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Watch the exceptions: das Mädchen is neuter because -chen '
                'controls grammatical gender; die Kenntnis and die Erlaubnis '
                'show why -nis is only a tendency; der Moment is a familiar '
                'exception to the usual -ment clue.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderCount extends StatelessWidget {
  const _GenderCount({required this.article, required this.count});

  final String article;
  final int count;

  @override
  Widget build(BuildContext context) {
    final GermanWord sample = GermanWord(
      id: '',
      article: article,
      german: '',
      plural: '',
      english: '',
      exampleGerman: '',
      exampleEnglish: '',
      category: '',
      level: 'A1',
    );
    final Color color = sample.genderColor(Theme.of(context).brightness);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.13),
          border: Border.all(color: color.withValues(alpha: 0.55)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: <Widget>[
            Text(article.toUpperCase(),
                style: TextStyle(color: color, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text('$count nouns', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.rule});

  final GenderEndingRule rule;

  @override
  Widget build(BuildContext context) {
    final List<GermanWord> examples = vocabulary
        .where((GermanWord word) {
          if (word.article != rule.gender.article) return false;
          final String lower = word.german.toLowerCase();
          return rule.endings.any(lower.endsWith);
        })
        .take(4)
        .toList(growable: false);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(rule.endingsLabel,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 17)),
                ),
                Chip(
                  label: Text(rule.strength == RuleStrength.reliable
                      ? 'strong clue'
                      : 'common clue'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(rule.note),
            if (examples.isNotEmpty) ...<Widget>[
              const SizedBox(height: 9),
              Text(
                examples
                    .map((GermanWord word) => word.displayGerman)
                    .join(' · '),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
