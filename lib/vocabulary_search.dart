import 'german_text.dart';
import 'models.dart';

/// Reference search accepts the same ASCII spelling as typed German practice.
/// Meanings in the learner's selected language supplement the English gloss.
bool vocabularyMatchesQuery(GermanWord word, String query, {String? meaning}) {
  String normalize(String value) =>
      foldUmlauts(value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' '));
  final String needle = normalize(query);
  if (needle.isEmpty) return true;
  return <String>[
    word.displayGerman,
    word.plural,
    word.english,
    ?meaning,
  ].any((String value) => normalize(value).contains(needle));
}
