import 'assessment.dart';
import 'test_prep.dart';
import 'l10n/app_localizations.dart';

String assessmentDomainText(AppText t, AssessmentDomain domain) =>
    switch (domain) {
      AssessmentDomain.vocabulary => t.skillVocabulary,
      AssessmentDomain.grammar => t.skillGrammar,
      AssessmentDomain.reading => t.skillReading,
      AssessmentDomain.listening => t.skillListening,
    };

String examModuleText(AppText t, ExamModuleType module) => switch (module) {
  ExamModuleType.reading => t.skillReading,
  ExamModuleType.listening => t.skillListening,
  ExamModuleType.writing => t.skillWriting,
  ExamModuleType.speaking => t.skillSpeaking,
};
