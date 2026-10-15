import 'conversation_engine.dart';
import 'l10n/app_localizations.dart';

String turnHeadline(AppText t, TurnEvaluation evaluation) =>
    switch (evaluation.feedbackKind) {
      TurnFeedbackKind.empty => t.turnEmpty,
      TurnFeedbackKind.excellent => t.turnExcellent,
      TurnFeedbackKind.accepted => t.turnAccepted,
      TurnFeedbackKind.short => t.turnShort,
      TurnFeedbackKind.offTopic => t.turnOffTopic,
      TurnFeedbackKind.missing => t.turnMissing,
      null => evaluation.headline,
    };

String turnDetail(AppText t, TurnEvaluation evaluation) =>
    switch (evaluation.feedbackKind) {
      TurnFeedbackKind.empty => t.turnEmptyDetail,
      TurnFeedbackKind.excellent => t.turnExcellentDetail,
      TurnFeedbackKind.accepted => t.turnAcceptedDetail,
      TurnFeedbackKind.short => t.turnShortDetail(evaluation.minWords),
      TurnFeedbackKind.offTopic => t.turnOffTopicDetail(evaluation.task),
      TurnFeedbackKind.missing => t.turnMissingDetail(
        evaluation.matched.length,
        evaluation.requiredHits,
      ),
      null => evaluation.detail,
    };
