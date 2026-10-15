import 'feedback_message.dart';
import 'l10n/app_localizations.dart';

String feedbackText(AppText t, FeedbackMessage message) =>
    switch (message.kind) {
      FeedbackKind.writingStart => t.writingTipStart(message.target),
      FeedbackKind.writingLength => t.writingTipLength(
        message.count,
        message.missing,
        message.target,
      ),
      FeedbackKind.writingKeywords => t.writingTipKeywords(message.words),
      FeedbackKind.writingNouns => t.writingTipNouns(message.words),
      FeedbackKind.writingSentenceCase => t.writingTipSentenceCase,
      FeedbackKind.writingConnectors => t.writingTipConnectors(message.words),
      FeedbackKind.writingParagraphs => t.writingTipParagraphs,
      FeedbackKind.writingRepetition => t.writingTipRepetition,
      FeedbackKind.writingSuccess => t.writingTipSuccess,
      FeedbackKind.speakingLength => t.speakingTipLength(
        message.count,
        message.target,
      ),
      FeedbackKind.speakingModels => t.speakingTipModels(
        message.covered,
        message.total,
      ),
      FeedbackKind.speakingConnectors => t.speakingTipConnectors,
      FeedbackKind.speakingSuccess => t.speakingTipSuccess,
      FeedbackKind.freeTalkMissing => t.freeTalkTipMissing(message.words),
      FeedbackKind.freeTalkLength => t.freeTalkTipLength(
        message.count,
        message.target,
      ),
      FeedbackKind.freeTalkConnectors => t.freeTalkTipConnectors(message.words),
      FeedbackKind.freeTalkTooLong => t.freeTalkTipTooLong,
      FeedbackKind.freeTalkSuccess => t.freeTalkTipSuccess,
    };

List<String> feedbackTexts(
  AppText t,
  List<FeedbackMessage> messages,
  List<String> legacy,
) => messages.isEmpty
    ? legacy
    : messages.map((m) => feedbackText(t, m)).toList();
