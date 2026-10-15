import 'pronunciation.dart';
import 'grammar_challenge.dart';
import 'l10n/app_localizations.dart';

String grammarFeatureLabel(AppText t, GrammarFeature feature) =>
    switch (feature) {
      GrammarFeature.nominativeArticles => t.gameFeatureNominativeArticles,
      GrammarFeature.accusativeAfterPrepositions =>
        t.gameFeatureAccusativeAfterPrepositions,
      GrammarFeature.dativeAfterPrepositions =>
        t.gameFeatureDativeAfterPrepositions,
      GrammarFeature.twoWayPrepositions => t.gameFeatureTwoWayPrepositions,
      GrammarFeature.adjectiveEndings => t.gameFeatureAdjectiveEndings,
      GrammarFeature.perfektAuxiliary => t.gameFeaturePerfektAuxiliary,
      GrammarFeature.separableVerbs => t.gameFeatureSeparableVerbs,
      GrammarFeature.reflexives => t.gameFeatureReflexives,
      GrammarFeature.konjunktivII => t.gameFeatureKonjunktivII,
      GrammarFeature.passive => t.gameFeaturePassive,
      GrammarFeature.relativePronouns => t.gameFeatureRelativePronouns,
      GrammarFeature.genitiv => t.gameFeatureGenitiv,
    };

String grammarFeatureDescription(
  AppText t,
  GrammarFeature feature,
) => switch (feature) {
  GrammarFeature.nominativeArticles =>
    t.gameFeatureNominativeArticlesDescription,
  GrammarFeature.accusativeAfterPrepositions =>
    t.gameFeatureAccusativeAfterPrepositionsDescription,
  GrammarFeature.dativeAfterPrepositions =>
    t.gameFeatureDativeAfterPrepositionsDescription,
  GrammarFeature.twoWayPrepositions =>
    t.gameFeatureTwoWayPrepositionsDescription,
  GrammarFeature.adjectiveEndings => t.gameFeatureAdjectiveEndingsDescription,
  GrammarFeature.perfektAuxiliary => t.gameFeaturePerfektAuxiliaryDescription,
  GrammarFeature.separableVerbs => t.gameFeatureSeparableVerbsDescription,
  GrammarFeature.reflexives => t.gameFeatureReflexivesDescription,
  GrammarFeature.konjunktivII => t.gameFeatureKonjunktivIIDescription,
  GrammarFeature.passive => t.gameFeaturePassiveDescription,
  GrammarFeature.relativePronouns => t.gameFeatureRelativePronounsDescription,
  GrammarFeature.genitiv => t.gameFeatureGenitivDescription,
};

String recognisedWordsVerdict(AppText t, PronunciationResult result) {
  if (result.isEmpty) return t.pronunciationVerdictEmpty;
  if (result.score >= 92) return t.pronunciationVerdictExcellent;
  if (result.score >= 80) return t.pronunciationVerdictGood;
  if (result.score >= 65) return t.pronunciationVerdictPractice;
  if (result.score >= 45) return t.pronunciationVerdictRepeat;
  return t.pronunciationVerdictFar;
}

String mistakeSourceText(AppText t, String source) => switch (source) {
  'all' => t.gameSourceAll,
  'vocabulary' => t.skillVocabulary,
  'grammar' => t.skillGrammar,
  'listening' => t.skillListening,
  'reading' => t.skillReading,
  'dictation' => t.gameDictation,
  'story' || 'mini-story' => t.storiesTitle,
  'radio' => 'Gartenradio',
  'sentence-builder' => t.gameSentenceBuilder,
  _ => t.gameSourceOther,
};
