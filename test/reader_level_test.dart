import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/stories_expansion.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('expanded readers stay inside cumulative level vocabulary', () {
    final Map<CefrLevel, Set<String>> allowed = <CefrLevel, Set<String>>{};
    for (final CefrLevel level in CefrLevel.values) {
      final Set<String> tokens = <String>{};
      for (final GermanWord word in vocabulary.where(
        (GermanWord word) =>
            CefrLevel.values
                .firstWhere((value) => value.label == word.level)
                .order <=
            level.order,
      )) {
        tokens.addAll(
          _tokens(
            '${word.article} ${word.german} ${word.plural} ${word.exampleGerman}',
          ),
        );
      }
      allowed[level] = tokens;
    }

    final List<String> failures = <String>[];
    for (final story in expandedStories) {
      final List<String> tokens = _tokens(
        story.chapters
            .expand((chapter) => chapter.lines)
            .map((line) => line.german)
            .join(' '),
      ).toList(growable: false);
      final int known = tokens
          .where((token) => allowed[story.level]!.contains(token))
          .length;
      final double coverage = tokens.isEmpty ? 0 : known / tokens.length;
      if (coverage < 0.70) {
        failures.add('${story.id}: ${(coverage * 100).toStringAsFixed(1)}%');
      }
    }
    expect(
      failures,
      isEmpty,
      reason:
          'Readers below 70% cumulative deck coverage:\n'
          '${failures.join('\n')}',
    );
  });
}

Iterable<String> _tokens(String text) sync* {
  for (final Match match in RegExp(r'[A-Za-zÄÖÜäöüß]+').allMatches(text)) {
    final String token = _stem(match.group(0)!.toLowerCase());
    if (token.length >= 3) yield token;
  }
}

String _stem(String token) {
  for (final String ending in const <String>[
    'ern',
    'est',
    'en',
    'er',
    'es',
    'em',
    'e',
    'n',
    's',
    't',
  ]) {
    if (token.length - ending.length >= 4 && token.endsWith(ending)) {
      return token.substring(0, token.length - ending.length);
    }
  }
  return token;
}
