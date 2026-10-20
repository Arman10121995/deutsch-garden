/// Presentation of linguistic metadata, separate from the lexical classifiers.
library;

import 'curriculum_text.dart';
import 'l10n/app_localizations.dart';
import 'models.dart';
import 'vocabulary_metadata.dart';

String grammarLabelText(AppText t, GermanWord word) {
  final label = curriculumText(t, word.wordClass.label);
  final gender = word.nounGender;
  return gender == null
      ? label
      : '$label · ${curriculumText(t, gender.label)} (${gender.article})';
}

String genderEndingText(AppText t, GermanWord word) {
  final match = genderEndingFor(word);
  if (match == null) {
    return word.nounGender == null
        ? curriculumText(t, word.wordClass.learningNote)
        : t.genderNoRule(word.article.toLowerCase());
  }
  final rule = match.rule;
  final tendency = rule.strength == RuleStrength.reliable
      ? t.genderStrongTendency(rule.gender.article)
      : t.genderCommonTendency(rule.gender.article);
  return rule.gender.article == word.article.toLowerCase()
      ? t.genderEndingAgrees(
          match.ending,
          curriculumText(t, rule.note),
          tendency,
        )
      : t.genderEndingException(match.ending, word.displayGerman, tendency);
}
